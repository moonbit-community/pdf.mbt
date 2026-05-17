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
const UINT_MAX : UInt = 0xffffffff

///|
const UINT64_MAX : UInt64 = 0xffffffffffffffffUL

///|
/// Parses a BytesView into a UInt64 number using the specified base, or returns an error.
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
/// ```mbt nocheck
///   inspect(@lexer_bytes.tokenize_uint64("123"), content="(123, 3)")
///   inspect(@lexer_bytes.tokenize_uint64("0xff", base=0), content="(255, 4)")
///   inspect(@lexer_bytes.tokenize_uint64("0o10"), content="(8, 4)")
///   inspect(@lexer_bytes.tokenize_uint64("0b1010"), content="(10, 6)")
///   inspect(@lexer_bytes.tokenize_uint64("1_234"), content="(1234, 5)")
///   inspect(@lexer_bytes.tokenize_uint64("ff", base=16), content="(255, 2)")
///   inspect(@lexer_bytes.tokenize_uint64("zz", base=36), content="(1295, 2)")
/// ```
/// 
pub fn tokenize_uint64(
  str : BytesView,
  base? : Int = 0,
) -> (UInt64, Int) raise LexError {
  guard str != b"" else { syntax_err() }
  let original_length = str.length()
  if str is [b'+' | b'-', ..] {
    syntax_err()
  }

  // `allow_underscore` is used to check validity of underscores
  let (num_base, rest, allow_underscore) = check_and_consume_base(str, base)

  // calculate overflow threshold
  let overflow_threshold = match num_base {
    10 => UINT64_MAX / 10 + 1
    16 => UINT64_MAX / 16 + 1
    _ => UINT64_MAX / num_base.to_uint64() + 1
  }
  let has_digit = rest
    is ([b'0'..=b'9' | b'a'..=b'z' | b'A'..=b'Z', ..]
    | [b'_', b'0'..=b'9' | b'a'..=b'z' | b'A'..=b'Z', ..])
  guard has_digit else { syntax_err() }
  let result = for rest = rest, acc = 0UL, allow_underscore = allow_underscore {
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
        guard acc < overflow_threshold else { range_err() }
        let next_acc = acc * num_base.to_uint64() + d.to_uint64()
        guard next_acc >= acc && next_acc <= UINT64_MAX else { range_err() }
        continue rest, next_acc, true
      }
      ([], acc, _) => break acc
    }
  }
  (result, original_length)
}

///|
fn tokenize_uint64_as_result(
  str : BytesView,
  base? : Int = 0,
) -> Result[(UInt64, Int), String] {
  Result::Ok(tokenize_uint64(str, base~)) catch {
    LexError(err) => Err(err)
  }
}

///|
/// Parse a BytesView in the given base (0, 2 to 36), return an UInt number and advance length, or an error.
/// If the `~base` argument is 0, the base will be inferred by the prefix.
pub fn tokenize_uint(
  str : BytesView,
  base? : Int = 0,
) -> (UInt, Int) raise LexError {
  let (n, len) = tokenize_uint64(str, base~)
  if n > UINT_MAX.to_uint64() {
    range_err()
  }
  (n.to_uint(), len)
}

///|
test "tokenize_uint64" {
  let tests : Array[(BytesView, Result[(UInt64, Int), String])] = [
    (b"", Err(syntax_err_str)),
    (b"0", Ok((0UL, 1))),
    (b"-0", Err(syntax_err_str)),
    (b"+0", Err(syntax_err_str)),
    (b"1", Ok((1UL, 1))),
    (b"-1", Err(syntax_err_str)),
    (b"12345", Ok((12345UL, 5))),
    (b"-12345", Err(syntax_err_str)),
    (b"012345", Ok((12345UL, 6))),
    (b"9876543210", Ok((9876543210UL, 10))),
    (b"18446744073709551615", Ok((18446744073709551615UL, 20))),
    (b"18446744073709551616", Err(range_err_str)),
    (b"1_2_3_4_5", Ok((12345UL, 9))),
    (b"_12345", Err(syntax_err_str)),
    (b"1__2345", Err(syntax_err_str)),
    (b"12345_", Err(syntax_err_str)),
    (b"12345%", Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    @debug.assert_eq(
      Result::Ok(tokenize_uint64(t.0)) catch {
        LexError(err) => Err(err)
      },
      t.1,
    )
  }
}

///|
test "tokenize_uint64_base" {
  let tests : Array[(BytesView, Int, Result[(UInt64, Int), String])] = [
    (b"", 0, Err(syntax_err_str)),
    (b"0", 0, Ok((0UL, 1))),
    (b"1", 0, Ok((1UL, 1))),
    (b"12345", 0, Ok((12345UL, 5))),
    (b"012345", 0, Ok((12345UL, 6))),
    (b"0x12345", 0, Ok((0x12345UL, 7))),
    (b"9876543210", 0, Ok((9876543210UL, 10))),
    (b"18446744073709551615", 0, Ok((UINT64_MAX, 20))),
    (b"0xffffffffffffffff", 0, Ok((UINT64_MAX, 18))),
    (b"18446744073709551616", 0, Err(range_err_str)),
    (b"12345x", 0, Err(syntax_err_str)),
    (b"-12345x", 0, Err(syntax_err_str)),
    // other bases
    (b"h", 18, Ok((17UL, 1))),
    (b"10", 25, Ok((25UL, 2))),
    (
      b"moonbit",
      35,
      Ok(
        (
          (
            ((((22UL * 35UL + 24UL) * 35UL + 24UL) * 35UL + 23UL) * 35UL + 11UL) *
            35UL +
            18UL
          ) *
          35UL +
          29UL,
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
            ((((22UL * 36UL + 24UL) * 36UL + 24UL) * 36UL + 23UL) * 36UL + 11UL) *
            36UL +
            18UL
          ) *
          36UL +
          29UL,
          7,
        ),
      ),
    ),
    // base 2
    (b"0", 2, Ok((0UL, 1))),
    (b"-1", 2, Err(syntax_err_str)),
    (b"1010", 2, Ok((10UL, 4))),
    (b"1000000000000000", 2, Ok((1UL << 15, 16))),
    (
      b"1111111111111111111111111111111111111111111111111111111111111111",
      2,
      Ok((UINT64_MAX, 64)),
    ),
    (
      b"1000000000000000000000000000000000000000000000000000000000000000",
      2,
      Ok((1UL << 63, 64)),
    ),
    // base 8
    (b"10", 8, Ok((8UL, 2))),
    (b"57635436545", 8, Ok((0o57635436545UL, 11))),
    (b"100000000", 8, Ok((1UL << 24, 9))),
    // base 16
    (b"10", 16, Ok((16UL, 2))),
    (b"ffffffffffffffff", 16, Ok((UINT64_MAX, 16))),
    // underscores
    (b"0x_1_2_3_4_5", 0, Ok((0x12345UL, 12))),
    (b"-_0x12345", 0, Err(syntax_err_str)),
    (b"_-0x12345", 0, Err(syntax_err_str)),
    (b"_0x12345", 0, Err(syntax_err_str)),
    (b"0x__12345", 0, Err(syntax_err_str)),
    (b"0x1__2345", 0, Err(syntax_err_str)),
    (b"0x1234__5", 0, Err(syntax_err_str)),
    (b"0x12345_", 0, Err(syntax_err_str)),
    (b"0_1_2_3_4_5", 0, Ok((12345UL, 11))),
    (b"-_012345", 0, Err(syntax_err_str)),
    (b"_-012345", 0, Err(syntax_err_str)),
    (b"_012345", 0, Err(syntax_err_str)),
    (b"0__12345", 0, Err(syntax_err_str)),
    (b"01234__5", 0, Err(syntax_err_str)),
    (b"012345_", 0, Err(syntax_err_str)),
    (b"0xf", 0, Ok((0xfUL, 3))),
    (b"-0xf", 0, Err(syntax_err_str)),
    (b"0x+f", 0, Err(syntax_err_str)),
    (b"0x-f", 0, Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    @debug.assert_eq(
      Result::Ok(tokenize_uint64(t.0, base=t.1)) catch {
        LexError(err) => Err(err)
      },
      t.2,
    )
  }
}

///|
test "tokenize_uint" {
  let tests : Array[(BytesView, Result[(UInt, Int), String])] = [
    (b"", Err(syntax_err_str)),
    (b"0", Ok((0, 1))),
    (b"-0", Err(syntax_err_str)),
    (b"+0", Err(syntax_err_str)),
    (b"1", Ok((1, 1))),
    (b"-1", Err(syntax_err_str)),
    (b"12345", Ok((12345, 5))),
    (b"012345", Ok((12345, 6))),
    (b"12345x", Err(syntax_err_str)),
    (b"-12345x", Err(syntax_err_str)),
    (b"987654321", Ok((987654321, 9))),
    (b"4294967295", Ok((UINT_MAX, 10))),
    (b"0xffffffff", Ok((UINT_MAX, 10))),
    (b"4294967296", Err(range_err_str)),
    (b"1_2_3_4_5", Ok((12345, 9))),
    (b"-_12345", Err(syntax_err_str)),
    (b"_12345", Err(syntax_err_str)),
    (b"1__2345", Err(syntax_err_str)),
    (b"12345_", Err(syntax_err_str)),
    (b"123%45", Err(syntax_err_str)),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    @debug.assert_eq(
      Result::Ok(tokenize_uint(t.0)) catch {
        LexError(err) => Err(err)
      },
      t.1,
    )
  }
}

///|
test "tokenize_uint64 uppercase hex and invalid base" {
  @debug.assert_eq(
    tokenize_uint64_as_result(b"ABCD", base=16),
    Ok((43981UL, 4)),
  )
  @debug.assert_eq(
    tokenize_uint64_as_result(b"1234", base=37),
    Err(base_err_str),
  )
}
