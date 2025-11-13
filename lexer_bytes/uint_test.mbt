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
test "@lexer_bytes.tokenize_uint64/base_handling" {
  // Different bases with valid input
  inspect(
    try? @lexer_bytes.tokenize_uint64("FF", base=16),
    content="Ok((255, 2))",
  )
  inspect(try? @lexer_bytes.tokenize_uint64("0xFF"), content="Ok((255, 4))")
  inspect(
    try? @lexer_bytes.tokenize_uint64("377", base=8),
    content="Ok((255, 3))",
  )
  inspect(try? @lexer_bytes.tokenize_uint64("0o377"), content="Ok((255, 5))")
  inspect(
    try? @lexer_bytes.tokenize_uint64("11111111", base=2),
    content="Ok((255, 8))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0b11111111"),
    content="Ok((255, 10))",
  )
}

///|
test "@lexer_bytes.tokenize_uint64/underscore" {
  // Valid underscore placements
  inspect(
    try? @lexer_bytes.tokenize_uint64("1_000_000"),
    content="Ok((1000000, 9))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xff_ff_ff"),
    content="Ok((16777215, 10))",
  )
  // Invalid underscore placements
  inspect(
    try? @lexer_bytes.tokenize_uint64("_123"),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("123_"),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("1__23"),
    content="Err(invalid syntax)",
  )
}

///|
test "panic @lexer_bytes.tokenize_uint64/errors" {
  // Empty BytesView
  ignore(@lexer_bytes.tokenize_uint64(""))
  // Invalid base
  ignore(@lexer_bytes.tokenize_uint64("123", base=37))
  // Signs not allowed
  ignore(@lexer_bytes.tokenize_uint64("+123"))
  ignore(@lexer_bytes.tokenize_uint64("-123"))
  // Range error (overflow)
  ignore(@lexer_bytes.tokenize_uint64("18446744073709551616"))
}

///|
test "@lexer_bytes.tokenize_uint64/hex_and_edge_cases" {
  // Valid hexadecimal numbers with 0x/0X prefix
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xDEADBEEF"),
    content="Ok((3735928559, 10))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0XDEADBEEF"),
    content="Ok((3735928559, 10))",
  )

  // Valid hexadecimal numbers without prefix when base=16 is specified
  inspect(
    try? @lexer_bytes.tokenize_uint64("deadbeef", base=16),
    content="Ok((3735928559, 8))",
  )

  // Valid hexadecimal numbers with allowed underscore placements
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xDEAD_BEEF"),
    content="Ok((3735928559, 11))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("dead_beef", base=16),
    content="Ok((3735928559, 9))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0x1_2345"),
    content="Ok((74565, 8))",
  )

  // Edge case: zero value
  inspect(try? @lexer_bytes.tokenize_uint64("0x0"), content="Ok((0, 3))")
  inspect(try? @lexer_bytes.tokenize_uint64("0x00"), content="Ok((0, 4))")

  // Edge case: maximum valid uint64 value (all bits set)
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xFFFFFFFFFFFFFFFF"),
    content="Ok((18446744073709551615, 18))",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xDEADBEEF_"),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xDE__AD_BEEF"),
    content="Err(invalid syntax)",
  )

  // Invalid hex digit (G is not a valid base-16 digit)
  inspect(
    try? @lexer_bytes.tokenize_uint64("0xDEADBEG"),
    content="Err(invalid syntax)",
  )
}

///|
test "edge cases" {
  // Invalid: Missing digits after hex prefix
  inspect(
    try? @lexer_bytes.tokenize_uint64("0x"),
    content="Err(invalid syntax)",
  )
  inspect(
    try? @lexer_bytes.tokenize_uint64("0x_"),
    content="Err(invalid syntax)",
  )

  // Underscore is allowed between the prefix and the first digit
  inspect(
    try? @lexer_bytes.tokenize_uint64("0x_DEADBEEF"),
    content="Ok((3735928559, 11))",
  )
}
