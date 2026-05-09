// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
const INT_MIN = 0x80000000

///|
const INT_MAX = 0x7fffffff

///|
const INT64_MIN = -0x8000000000000000L

///|
const INT64_MAX = 0x7fffffffffffffffL

///|
/// This function check whether the prefix of the BytesView is consistent with the given base,
/// and consume the prefix.
/// The boolean flag `allow_underscore` is used to check validity of underscores.
fn check_and_consume_base(
  view : BytesView,
  base : Int,
) -> (Int, BytesView, Bool) raise LexError {
  // if the base is not given, we need to determine it from the prefix
  if base == 0 {
    match view {
      [b'0', b'x' | b'X', .. rest] => (16, rest, true)
      [b'0', b'o' | b'O', .. rest] => (8, rest, true)
      [b'0', b'b' | b'B', .. rest] => (2, rest, true)
      _ => (10, view, false)
    }
  } else {
    // if the base is given, we need to check whether the prefix is consistent with it
    match view {
      [b'0', b'x' | b'X', .. rest] if base == 16 => (16, rest, true)
      [b'0', b'o' | b'O', .. rest] if base == 8 => (8, rest, true)
      [b'0', b'b' | b'B', .. rest] if base == 2 => (2, rest, true)
      _ => if base is (2..=36) { (base, view, false) } else { base_err() }
    }
  }
}

///|
test {
  inspect(try? tokenize_int64(b"0b01", base=3), content="Err(invalid syntax)")
  inspect(try? tokenize_int64(b"0x01", base=3), content="Err(invalid syntax)")
  inspect(try? tokenize_int64(b"0o01", base=3), content="Err(invalid syntax)")
}

///|
/// Parses a BytesView into an Int64 number using the specified base, or returns an error.
/// The base must be 0 or between 2 and 36 (inclusive). If base is 0, it will be 
/// inferred from the BytesView prefix:
///   - "0x" or "0X" for base 16 (hex)
///   - "0o" or "0O" for base 8 (octal) 
///   - "0b" or "0B" for base 2 (binary)
///   - Default is base 10 (decimal)
/// For readability, underscores may appear after base prefixes or between digits.
/// These underscores do not affect the value.
/// Returns a tuple of (parsed_value, advance_length).
/// Examples:
/// ```mbt
///   inspect(@lexer_bytes.tokenize_int64("123"), content="(123, 3)")
///   inspect(@lexer_bytes.tokenize_int64("0xff", base=0), content="(255, 4)") 
///   inspect(@lexer_bytes.tokenize_int64("0o10"), content="(8, 4)")
///   inspect(@lexer_bytes.tokenize_int64("0b1010"), content="(10, 6)")
///   inspect(@lexer_bytes.tokenize_int64("1_234"), content="(1234, 5)")
///   inspect(@lexer_bytes.tokenize_int64("-123"), content="(-123, 4)")
///   inspect(@lexer_bytes.tokenize_int64("ff", base=16), content="(255, 2)")
///   inspect(@lexer_bytes.tokenize_int64("zz", base=36), content="(1295, 2)")
/// ```
/// 
pub fn tokenize_int64(
  str : BytesView,
  base? : Int = 0,
) -> (Int64, Int) raise LexError {
  guard str != b"" else { syntax_err() }
  let original_length = str.length()
  let (neg, rest) = match str {
    [b'+', .. rest] => (false, rest)
    [b'-', .. rest] => (true, rest)
    rest => (false, rest)
  }

  // `allow_underscore` is used to check validity of underscores
  let (num_base, rest, allow_underscore) = check_and_consume_base(rest, base)

  // calculate overflow threshold
  let overflow_threshold = overflow_threshold(num_base, neg)
  let has_digit = rest
    is ([b'0'..=b'9' | b'a'..=b'z' | b'A'..=b'Z', ..]
    | [b'_', b'0'..=b'9' | b'a'..=b'z' | b'A'..=b'Z', ..])
  guard has_digit else { syntax_err() }
  // convert
  let result = for rest = rest, acc = 0L, allow_underscore = allow_underscore {
    match (rest, acc, allow_underscore) {
    ([b'_'], _, _) =>
      // the last character cannot be underscore
      syntax_err()
    ([b'_', ..], _, false) => syntax_err()
    ([b'_', .. rest], acc, true) => continue rest, acc, false
    ([c, .. rest], acc, _) => {
      let c = c.to_int()
      let d = match c {
        '0'..='9' => c - '0'
        'a'..='z' => c + (10 - 'a')
        'A'..='Z' => c + (10 - 'A')
        _ => syntax_err()
      }
      guard d < num_base else { syntax_err() }
      if neg {
        guard acc >= overflow_threshold else { range_err() }
        let next_acc = acc * num_base.to_int64() - d.to_int64()
        guard next_acc <= acc else { range_err() }
        continue rest, next_acc, true
      } else {
        guard acc < overflow_threshold else { range_err() }
        let next_acc = acc * num_base.to_int64() + d.to_int64()
        guard next_acc >= acc else { range_err() }
        continue rest, next_acc, true
      }
    }
    ([], acc, _) => break acc
    }
  }
  (result, original_length)
}

///|
/// Parse a BytesView in the given base (0, 2 to 36), return a Int number and advance length, or an error.
/// If the `~base` argument is 0, the base will be inferred by the prefix.
pub fn tokenize_int(
  str : BytesView,
  base? : Int = 0,
) -> (Int, Int) raise LexError {
  let (n, len) = tokenize_int64(str, base~)
  if n < INT_MIN.to_int64() || n > INT_MAX.to_int64() {
    range_err()
  }
  (n.to_int(), len)
}

// Check whether the underscores are correct.
// Underscores must appear only between digits or between a base prefix and a digit.

///|
fn check_underscore(str : BytesView) -> Bool {
  // skip the sign
  let rest = match str {
    [b'+' | b'-', .. rest] => rest
    rest => rest
    // CR: the type maybe a bit confusing?
  }

  // base prefix
  let (rest, allow_underscore, hex) = match rest {
    [b'0', b'x' | b'X', .. rest] => (rest, true, true)
    [b'0', b'o' | b'O', .. rest] => (rest, true, false)
    [b'0', b'b' | b'B', .. rest] => (rest, true, false)
    rest => (rest, false, false)
  }

  // 'e' and 'E' are valid hex digits
  // but are not treated as digits in decimal BytesViews since they're used for scientific notation
  fn is_digit(c : Byte) -> Bool {
    c is (b'0'..=b'9') || (hex && c is (b'a'..=b'f' | b'A'..=b'F'))
  }

  // Track whether the previous character was an underscore
  let follow_underscore = false
  for rest = rest, allow_underscore = allow_underscore, follow_underscore = follow_underscore {
    match (rest, allow_underscore, follow_underscore) {
    // Empty BytesView is valid
    ([], _, _) => break true
    // BytesView ending with underscore is invalid
    ([b'_'], _, _) => break false
    // Underscore not allowed in current position (e.g., between non-digits)
    ([b'_', ..], false, _) => break false
    // Valid underscore - continue but mark that next char must be a digit
    ([b'_', .. rest], true, _) => continue rest, false, true
    // Handle non-underscore character
    ([c, .. rest], _, follow_underscore) =>
      if is_digit(c) {
        // Digit found - allow underscore in next position
        continue rest, true, false
      } else if follow_underscore {
        // Non-digit found after underscore - invalid
        break false
      } else {
        // Non-digit found (not after underscore) - continue but don't allow underscores
        continue rest, false, false
      }
    }
  }
}

// Determine the base of the value.

///|
fn determine_base(s : BytesView) -> Int {
  match s {
    [b'0', b'x' | b'X', ..] => 16
    [b'0', b'o' | b'O', ..] => 8
    [b'0', b'b' | b'B', ..] => 2
    _ => 10
  }
}

///|
fn overflow_threshold(base : Int, neg : Bool) -> Int64 {
  if !neg {
    if base == 10 {
      INT64_MAX / 10L + 1L
    } else if base == 16 {
      INT64_MAX / 16L + 1L
    } else {
      INT64_MAX / base.to_int64() + 1L
    }
  } else if base == 10 {
    INT64_MIN / 10L
  } else if base == 16 {
    INT64_MIN / 16L
  } else {
    INT64_MIN / base.to_int64()
  }
}

///|
test "check_underscore" {
  assert_true(check_underscore(b"123"))
  assert_true(check_underscore(b"0x123"))
  assert_true(check_underscore(b"0o123"))
  assert_true(check_underscore(b"0b101"))
  assert_true(check_underscore(b"1_2_3"))
  assert_true(check_underscore(b"0x_1_2_3_A_F"))
  assert_true(check_underscore(b"0o_1_2_3"))
  assert_true(check_underscore(b"0b_1_0_1"))
  assert_false(check_underscore(b"1__2_3"))
  assert_false(check_underscore(b"_123"))
  assert_false(check_underscore(b"123_"))
}

///|
test "determine_base" {
  inspect(determine_base(b"1234"), content="10")
  inspect(determine_base(b"0x1234"), content="16")
  inspect(determine_base(b"0X1234"), content="16")
  inspect(determine_base(b"0o1234"), content="8")
  inspect(determine_base(b"0O1234"), content="8")
  inspect(determine_base(b"0b1010"), content="2")
  inspect(determine_base(b"0B1010"), content="2")
}

///|
test "tokenize_int64" {
  let tests : Array[(BytesView, Result[(Int64, Int), String])] = [
    (b"", Err(syntax_err_str)),
    (b"0", Ok((0L, 1))),
    (b"-0", Ok((0L, 2))),
    (b"+0", Ok((0L, 2))),
    (b"1", Ok((1L, 1))),
    (b"-1", Ok((-1L, 2))),
    (b"+1", Ok((1L, 2))),
    (b"12345", Ok((12345L, 5))),
    (b"-12345", Ok((-12345L, 6))),
    (b"012345", Ok((12345L, 6))),
    (b"-012345", Ok((-12345L, 7))),
    (b"9876543210", Ok((9876543210L, 10))),
    (b"-9876543210", Ok((-9876543210L, 11))),
    (b"9223372036854775807", Ok((9223372036854775807L, 19))),
    (b"-9223372036854775807", Ok((-9223372036854775807L, 20))),
    (b"9223372036854775808", Err(range_err_str)),
    (b"-9223372036854775808", Ok((-9223372036854775808L, 20))),
    (b"9223372036854775809", Err(range_err_str)),
    (b"-9223372036854775809", Err(range_err_str)),
    (b"-1_2_3_4_5", Ok((-12345L, 10))),
    (b"-_12345", Err(syntax_err_str)),
    (b"_12345", Err(syntax_err_str)),
    (b"1__2345", Err(syntax_err_str)),
    (b"12345_", Err(syntax_err_str)),
    (b"12345%", Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    assert_eq(
      Result::Ok(tokenize_int64(t.0)) catch {
        LexError(err) => Err(err)
      },
      t.1,
    )
  }
}

///|
test "tokenize_int64_base" {
  let tests : Array[(BytesView, Int, Result[(Int64, Int), String])] = [
    (b"", 0, Err(syntax_err_str)),
    (b"0", 0, Ok((0L, 1))),
    (b"-0", 0, Ok((0L, 2))),
    (b"1", 0, Ok((1L, 1))),
    (b"-1", 0, Ok((-1L, 2))),
    (b"12345", 0, Ok((12345L, 5))),
    (b"-12345", 0, Ok((-12345L, 6))),
    (b"012345", 0, Ok((12345L, 6))),
    (b"-012345", 0, Ok((-12345L, 7))),
    (b"0x12345", 0, Ok((0x12345L, 7))),
    (b"-0x12345", 0, Ok((-0x12345L, 8))),
    (b"9876543210", 0, Ok((9876543210L, 10))),
    (b"-9876543210", 0, Ok((-9876543210L, 11))),
    (b"9223372036854775807", 0, Ok((9223372036854775807L, 19))),
    (b"-9223372036854775807", 0, Ok((-9223372036854775807L, 20))),
    (b"9223372036854775808", 0, Err(range_err_str)),
    (b"12345x", 0, Err(syntax_err_str)),
    (b"-12345x", 0, Err(syntax_err_str)),
    (b"-9223372036854775808", 0, Ok((-9223372036854775808L, 20))),
    (b"9223372036854775809", 0, Err(range_err_str)),
    (b"-9223372036854775809", 0, Err(range_err_str)),
    // other bases
    (b"h", 18, Ok((17L, 1))),
    (b"10", 25, Ok((25L, 2))),
    (
      b"moonbit",
      35,
      Ok(
        (
          (
            ((((22L * 35L + 24L) * 35L + 24L) * 35L + 23L) * 35L + 11L) * 35L +
            18L
          ) *
          35L +
          29L,
          7,
        ),
      ),
    ),
    (
      b"moonbit",
      36,
      Ok(
        (
          (
            ((((22L * 36L + 24L) * 36L + 24L) * 36L + 23L) * 36L + 11L) * 36L +
            18L
          ) *
          36L +
          29L,
          7,
        ),
      ),
    ),
    // base 2
    (b"0", 2, Ok((0L, 1))),
    (b"-1", 2, Ok((-1L, 2))),
    (b"1010", 2, Ok((10L, 4))),
    (b"1000000000000000", 2, Ok((1L << 15, 16))),
    (
      b"111111111111111111111111111111111111111111111111111111111111111",
      2,
      Ok(((1L << 63) - 1L, 63)),
    ),
    (
      b"1000000000000000000000000000000000000000000000000000000000000000",
      2,
      Err(range_err_str),
    ),
    (
      b"-1000000000000000000000000000000000000000000000000000000000000000",
      2,
      Ok((-1L << 63, 65)),
    ),
    (
      b"-1000000000000000000000000000000000000000000000000000000000000001",
      2,
      Err(range_err_str),
    ),
    // base 8
    (b"-10", 8, Ok((-8L, 3))),
    (b"57635436545", 8, Ok((0o57635436545L, 11))),
    (b"100000000", 8, Ok((1L << 24, 9))),
    // base 16
    (b"10", 16, Ok((16L, 2))),
    (b"-123456789abcdef", 16, Ok((-0x123456789abcdefL, 16))),
    (b"7fffffffffffffff", 16, Ok(((1L << 63) - 1L, 16))),
    // underscores
    (b"-0x_1_2_3_4_5", 0, Ok((-0x12345L, 13))),
    (b"0x_1_2_3_4_5", 0, Ok((0x12345L, 12))),
    (b"-_0x12345", 0, Err(syntax_err_str)),
    (b"_-0x12345", 0, Err(syntax_err_str)),
    (b"_0x12345", 0, Err(syntax_err_str)),
    (b"0x__12345", 0, Err(syntax_err_str)),
    (b"0x1__2345", 0, Err(syntax_err_str)),
    (b"0x1234__5", 0, Err(syntax_err_str)),
    (b"0x12345_", 0, Err(syntax_err_str)),
    (b"-0_1_2_3_4_5", 0, Ok((-12345L, 12))),
    (b"0_1_2_3_4_5", 0, Ok((12345L, 11))),
    (b"-_012345", 0, Err(syntax_err_str)),
    (b"_-012345", 0, Err(syntax_err_str)),
    (b"_012345", 0, Err(syntax_err_str)),
    (b"0__12345", 0, Err(syntax_err_str)),
    (b"01234__5", 0, Err(syntax_err_str)),
    (b"012345_", 0, Err(syntax_err_str)),
    (b"+0xf", 0, Ok((0xfL, 4))),
    (b"-0xf", 0, Ok((-0xfL, 4))),
    (b"0x+f", 0, Err(syntax_err_str)),
    (b"0x-f", 0, Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    assert_eq(
      Result::Ok(tokenize_int64(t.0, base=t.1)) catch {
        LexError(err) => Err(err)
      },
      t.2,
    )
  }
}

///|
test "tokenize_int" {
  let tests : Array[(BytesView, Result[(Int, Int), String])] = [
    (b"", Err(syntax_err_str)),
    (b"0", Ok((0, 1))),
    (b"-0", Ok((0, 2))),
    (b"1", Ok((1, 1))),
    (b"-1", Ok((-1, 2))),
    (b"12345", Ok((12345, 5))),
    (b"-12345", Ok((-12345, 6))),
    (b"012345", Ok((12345, 6))),
    (b"-012345", Ok((-12345, 7))),
    (b"12345x", Err(syntax_err_str)),
    (b"-12345x", Err(syntax_err_str)),
    (b"987654321", Ok((987654321, 9))),
    (b"-987654321", Ok((-987654321, 10))),
    (b"2147483647", Ok(((1 << 31) - 1, 10))),
    (b"-2147483647", Ok((-((1 << 31) - 1), 11))),
    (b"2147483648", Err(range_err_str)),
    (b"-2147483648", Ok((-1 << 31, 11))),
    (b"2147483649", Err(range_err_str)),
    (b"-2147483649", Err(range_err_str)),
    (b"-1_2_3_4_5", Ok((-12345, 10))),
    (b"-_12345", Err(syntax_err_str)),
    (b"_12345", Err(syntax_err_str)),
    (b"1__2345", Err(syntax_err_str)),
    (b"12345_", Err(syntax_err_str)),
    (b"123%45", Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    assert_eq(
      Result::Ok(tokenize_int(t.0)) catch {
        LexError(err) => Err(err)
      },
      t.1,
    )
  }
}
