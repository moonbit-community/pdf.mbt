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
/// Parse a BytesView and return the represented boolean value and advance length, or an error.
pub fn tokenize_bool(str : BytesView) -> (Bool, Int) raise LexError {
  match str {
    "1" | "t" | "T" | "true" | "TRUE" | "True" => (true, str.length())
    "0" | "f" | "F" | "false" | "FALSE" | "False" => (false, str.length())
    _ => syntax_err()
  }
}

///|
test "tokenize_bool" {
  let tests : Array[(BytesView, Result[(Bool, Int), String])] = [
    ("", Err(syntax_err_str)),
    ("zutomayo", Err(syntax_err_str)),
    ("0", Ok((false, 1))),
    ("f", Ok((false, 1))),
    ("F", Ok((false, 1))),
    ("FALSE", Ok((false, 5))),
    ("false", Ok((false, 5))),
    ("False", Ok((false, 5))),
    ("1", Ok((true, 1))),
    ("t", Ok((true, 1))),
    ("T", Ok((true, 1))),
    ("TRUE", Ok((true, 4))),
    ("true", Ok((true, 4))),
    ("True", Ok((true, 4))),
  ]
  for i in 0..<tests.length() {
    let t = tests[i]
    assert_eq(
      Result::Ok(tokenize_bool(t.0)) catch {
        LexError(err) => Err(err)
      },
      t.1,
    )
  }
}
