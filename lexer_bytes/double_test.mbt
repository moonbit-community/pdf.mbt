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
fn tokenize_double_as_result(str : BytesView) -> Result[(Double, Int), String] {
  Result::Ok(@lexer_bytes.tokenize_double(str)) catch {
    @lexer_bytes.LexError(err) => Err(err)
  }
}

///|
test "try_fast_path overflow when shift is too large" {
  // When the shift (exponent - max_exponent_fast_path) is too large,
  // the multiplication of mantissa with int_pow10[shift] will overflow,
  // triggering line 130
  let result = @lexer_bytes.tokenize_double(b"9007199254740992e30")
  // The function successfully falls back to slow path
  debug_inspect(result, content="(9.007199254740992e+45, 19)")
}

///|
test "try_fast_path overflow when mantissa is too large" {
  // When the mantissa after shifting is larger than max_mantissa_fast_path,
  // line 133 will be triggered
  let result = @lexer_bytes.tokenize_double(b"9007199254740992e23")
  // The function successfully falls back to slow path
  debug_inspect(result, content="(9.007199254740991e+38, 19)")
}

///|
test "corner cases" {
  @debug.assert_eq(tokenize_double_as_result(b".123"), Ok((0.123, 4)))
  @debug.assert_eq(tokenize_double_as_result(b"."), Err("invalid syntax"))
  @debug.assert_eq(tokenize_double_as_result(b"-"), Err("invalid syntax"))
}

///|
test "tokenize_double infinity and NaN with trailing characters should error" {
  // These should trigger the uncovered line 84 in tokenize_double
  // tokenize_inf_nan succeeds but doesn't consume the entire BytesView
  @debug.assert_eq(tokenize_double_as_result(b"infabc"), Err("invalid syntax"))
  @debug.assert_eq(tokenize_double_as_result(b"nanxyz"), Err("invalid syntax"))
  @debug.assert_eq(
    tokenize_double_as_result(b"+infinity123"),
    Err("invalid syntax"),
  )
  @debug.assert_eq(
    tokenize_double_as_result(b"-inf_extra"),
    Err("invalid syntax"),
  )
  @debug.assert_eq(tokenize_double_as_result(b"NaN!"), Err("invalid syntax"))
}
