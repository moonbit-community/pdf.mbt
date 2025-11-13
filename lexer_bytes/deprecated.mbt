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
/// High Precision Decimal structure for "Simple Decimal Conversion" algorithm.
/// Developed by Ken. Thompson, Russ Cox, Robert Griesemer, Nigel Tao.
///
/// reference:
/// - <https://nigeltao.github.io/blog/2020/parse-number-f64-simple.html>
/// - <https://nigeltao.github.io/blog/2020/eisel-lemire.html>
priv struct Decimal {
  digits : FixedArray[Byte]
  mut digits_num : Int
  mut decimal_point : Int
  mut negative : Bool
  mut truncated : Bool
}
