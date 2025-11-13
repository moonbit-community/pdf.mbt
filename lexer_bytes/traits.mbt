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

// TODO:
// 
// - Format functions.
// - Support hexadecimal floating point number.
// - Implements Eisel-Lemire algorithm to speed up floating point parsing.

///|
pub(open) trait FromBytesView {
  from(BytesView) -> (Self, Int) raise LexError
}

///|
pub impl FromBytesView for Bool with from(str) {
  tokenize_bool(str)
}

///|
pub impl FromBytesView for Int with from(str) {
  tokenize_int(str)
}

///|
pub impl FromBytesView for Int64 with from(str) {
  tokenize_int64(str)
}

///|
pub impl FromBytesView for UInt with from(str) {
  tokenize_uint(str)
}

///|
pub impl FromBytesView for UInt64 with from(str) {
  tokenize_uint64(str)
}

///|
pub impl FromBytesView for Double with from(str) {
  tokenize_double(str)
}

///|
pub fn[A : FromBytesView] tokenize(str : BytesView) -> (A, Int) raise LexError {
  A::from(str)
}

///|
test "parse" {
  let (b, b_len) : (Bool, Int) = tokenize("true")
  inspect(b, content="true")
  inspect(b_len, content="4")
  let (i, i_len) : (Int, Int) = tokenize("12345")
  inspect(i, content="12345")
  inspect(i_len, content="5")
  let (i64, i64_len) : (Int64, Int) = tokenize("9223372036854775807")
  assert_eq(i64, 9223372036854775807L)
  assert_eq(i64_len, 19)
  let (ui, ui_len) : (UInt, Int) = tokenize("4294967295")
  inspect(ui, content="4294967295")
  inspect(ui_len, content="10")
  let (ui64, ui64_len) : (UInt64, Int) = tokenize("18446744073709551615")
  assert_eq(ui64, 18446744073709551615UL)
  assert_eq(ui64_len, 20)
  let (d, d_len) : (Double, Int) = tokenize("1234.56789")
  assert_eq(d, 1234.56789)
  assert_eq(d_len, 10)
}
