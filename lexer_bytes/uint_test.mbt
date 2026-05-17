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
fn tokenize_uint64_as_result(
  s : BytesView,
  base? : Int = 0,
) -> Result[(UInt64, Int), String] {
  Result::Ok(@lexer_bytes.tokenize_uint64(s, base~)) catch {
    @lexer_bytes.LexError(err) => Err(err)
  }
}

///|
test "@lexer_bytes.tokenize_uint64/base_handling" {
  // Different bases with valid input
  @debug.assert_eq(tokenize_uint64_as_result(b"FF", base=16), Ok((255UL, 2)))
  @debug.assert_eq(tokenize_uint64_as_result(b"0xFF"), Ok((255UL, 4)))
  @debug.assert_eq(tokenize_uint64_as_result(b"377", base=8), Ok((255UL, 3)))
  @debug.assert_eq(tokenize_uint64_as_result(b"0o377"), Ok((255UL, 5)))
  @debug.assert_eq(
    tokenize_uint64_as_result(b"11111111", base=2),
    Ok((255UL, 8)),
  )
  @debug.assert_eq(tokenize_uint64_as_result(b"0b11111111"), Ok((255UL, 10)))
}

///|
test "@lexer_bytes.tokenize_uint64/underscore" {
  // Valid underscore placements
  @debug.assert_eq(tokenize_uint64_as_result(b"1_000_000"), Ok((1000000UL, 9)))
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xff_ff_ff"),
    Ok((16777215UL, 10)),
  )
  // Invalid underscore placements
  @debug.assert_eq(tokenize_uint64_as_result(b"_123"), Err("invalid syntax"))
  @debug.assert_eq(tokenize_uint64_as_result(b"123_"), Err("invalid syntax"))
  @debug.assert_eq(tokenize_uint64_as_result(b"1__23"), Err("invalid syntax"))
}

///|
test "panic @lexer_bytes.tokenize_uint64/errors" {
  // Empty BytesView
  ignore(@lexer_bytes.tokenize_uint64(b""))
  // Invalid base
  ignore(@lexer_bytes.tokenize_uint64(b"123", base=37))
  // Signs not allowed
  ignore(@lexer_bytes.tokenize_uint64(b"+123"))
  ignore(@lexer_bytes.tokenize_uint64(b"-123"))
  // Range error (overflow)
  ignore(@lexer_bytes.tokenize_uint64(b"18446744073709551616"))
}

///|
test "@lexer_bytes.tokenize_uint64/hex_and_edge_cases" {
  // Valid hexadecimal numbers with 0x/0X prefix
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xDEADBEEF"),
    Ok((3735928559UL, 10)),
  )
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0XDEADBEEF"),
    Ok((3735928559UL, 10)),
  )

  // Valid hexadecimal numbers without prefix when base=16 is specified
  @debug.assert_eq(
    tokenize_uint64_as_result(b"deadbeef", base=16),
    Ok((3735928559UL, 8)),
  )

  // Valid hexadecimal numbers with allowed underscore placements
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xDEAD_BEEF"),
    Ok((3735928559UL, 11)),
  )
  @debug.assert_eq(
    tokenize_uint64_as_result(b"dead_beef", base=16),
    Ok((3735928559UL, 9)),
  )
  @debug.assert_eq(tokenize_uint64_as_result(b"0x1_2345"), Ok((74565UL, 8)))

  // Edge case: zero value
  @debug.assert_eq(tokenize_uint64_as_result(b"0x0"), Ok((0UL, 3)))
  @debug.assert_eq(tokenize_uint64_as_result(b"0x00"), Ok((0UL, 4)))

  // Edge case: maximum valid uint64 value (all bits set)
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xFFFFFFFFFFFFFFFF"),
    Ok((18446744073709551615UL, 18)),
  )
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xDEADBEEF_"),
    Err("invalid syntax"),
  )
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xDE__AD_BEEF"),
    Err("invalid syntax"),
  )

  // Invalid hex digit (G is not a valid base-16 digit)
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0xDEADBEG"),
    Err("invalid syntax"),
  )
}

///|
test "edge cases" {
  // Invalid: Missing digits after hex prefix
  @debug.assert_eq(tokenize_uint64_as_result(b"0x"), Err("invalid syntax"))
  @debug.assert_eq(tokenize_uint64_as_result(b"0x_"), Err("invalid syntax"))

  // Underscore is allowed between the prefix and the first digit
  @debug.assert_eq(
    tokenize_uint64_as_result(b"0x_DEADBEEF"),
    Ok((3735928559UL, 11)),
  )
}
