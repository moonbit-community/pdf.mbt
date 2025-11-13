///|
const Byte_Digits = 8

///|
const UInt16_Digits = 16

///|
const Int16_Digits = 16

///|
const Int_Digits = 32

///|
const UInt_Digits = 32

///|
const Int64_Digits = 64

///|
const UInt64_Digits = 64

//|
/// Mathematical Derivation of Maximum Decimal Digits for Integer Types
///
/// Given:
/// - I is an integer type
/// - n is the bit width of type I  
/// - I_Max is the maximum value of type I
/// - pow(2,n) - 1 == I_Max (for unsigned types)
/// - pow(2,n-1) - 1 == I_Max (for signed types, considering sign bit)
///
/// Theorem: 
/// log₁₀(I_Max) represents the maximum count of decimal digits that can be 
/// represented by type I (excluding sign for negative numbers).
///
/// Since I_Max < pow(2,n), we have:
/// log₁₀(I_Max) < log₁₀(pow(2,n)) = n * log₁₀(2)
///
/// Using a bounding approach and the fact that we need integer digit counts:
/// The upper bound of decimal digits for type I is ⌊n * log₁₀(2)⌋ + 1
/// where the +1 accounts for potential rounding and sign representation.
///
/// Note: log₁₀(2) ≈ 0.30103, so n * log₁₀(2) gives us the theoretical maximum.

///|
/// Practical Constants for Maximum Decimal Digits
/// These constants represent the exact maximum decimal digits needed
/// to represent any value of the corresponding integer type.
///
/// https://en.cppreference.com/w/cpp/types/numeric_limits/digits10.html
///

///|
/// Maximum decimal digits for UInt8/Byte: 2^8 - 1 = 255 (3 digits)
/// Theoretical: ⌊8 * 0.30103⌋ + 1 = ⌊2.408⌋ + 1 = 3 ✓
const Byte_Digits10 = 3

///|
/// Maximum decimal digits for UInt16: 2^16 - 1 = 65535 (5 digits)  
/// Theoretical: ⌊16 * 0.30103⌋ + 1 = ⌊4.816⌋ + 1 = 5 ✓
const UInt16_Digits10 = 5

///|
/// Maximum decimal digits for Int16: -2^15 to 2^15 - 1 (-32768 to 32767)
/// Minimum value -32768 requires 6 digits including sign
/// Theoretical: ⌊15 * 0.30103⌋ + 2 = ⌊4.515⌋ + 2 = 6 ✓ (extra +1 for sign)
const Int16_Digits10 = 6

///|
/// Maximum decimal digits for UInt32/UInt: 2^32 - 1 = 4294967295 (10 digits)
/// Theoretical: ⌊32 * 0.30103⌋ + 1 = ⌊9.633⌋ + 1 = 10 ✓
const UInt_Digits10 = 10

///|
/// Maximum decimal digits for Int32/Int: -2^31 to 2^31 - 1 (-2147483648 to 2147483647)
/// Minimum value -2147483648 requires 11 digits including sign
/// Theoretical: ⌊31 * 0.30103⌋ + 2 = ⌊9.332⌋ + 2 = 11 ✓ (extra +1 for sign)
const Int_Digits10 = 11

///|
/// Maximum decimal digits for UInt64: 2^64 - 1 = 18446744073709551615 (20 digits)
/// Theoretical: ⌊64 * 0.30103⌋ + 1 = ⌊19.266⌋ + 1 = 20 ✓
const UInt64_Digits10 = 20

///|
/// Maximum decimal digits for Int64: -2^63 to 2^63 - 1
/// Minimum value -9223372036854775808 requires 20 digits including sign
/// Theoretical: ⌊63 * 0.30103⌋ + 2 = ⌊18.965⌋ + 2 = 20 ✓ (extra +1 for sign)
const Int64_Digits10 = 20

///|
/// Verification Tests
/// These tests verify that our theoretical calculations match practical reality
test "decimal digits constants verification" {
  // Byte: 2^8 - 1 = 255
  inspect((255).to_string().length(), content="3")
  inspect(Byte_Digits10, content="3")

  // UInt16: 2^16 - 1 = 65535
  inspect((65535).to_string().length(), content="5")
  inspect(UInt16_Digits10, content="5")

  // Int16: -2^15 = -32768
  inspect((-32768).to_string().length(), content="6")
  inspect(Int16_Digits10, content="6")

  // UInt: 2^32 - 1 = 4294967295
  inspect(4294967295U.to_string().length(), content="10")
  inspect(UInt_Digits10, content="10")

  // Int: -2^31 = -2147483648
  inspect((-2147483648).to_string().length(), content="11")
  inspect(Int_Digits10, content="11")
}

///|
/// Mathematical Proof Validation
/// This test demonstrates the mathematical relationship between bit width and decimal digits
test "mathematical proof validation" {
  // Verify that our constants follow the theoretical upper bound formula
  // For unsigned types: digits ≤ ⌊n * log₁₀(2)⌋ + 1
  // For signed types: digits ≤ ⌊(n-1) * log₁₀(2)⌋ + 2

  let log10_2 = @math.log10(2) // log₁₀(2) ≈ 0.30103

  // UInt8: ⌊8 * 0.30103⌋ + 1 = 3
  let byte_theoretical = (8.0 * log10_2).to_int() + 1
  inspect(byte_theoretical, content="3")
  inspect(Byte_Digits10 <= byte_theoretical, content="true")

  // UInt16: ⌊16 * 0.30103⌋ + 1 = 5  
  let uint16_theoretical = (16.0 * log10_2).to_int() + 1
  inspect(uint16_theoretical, content="5")
  inspect(UInt16_Digits10 <= uint16_theoretical, content="true")

  // Int16: ⌊15 * 0.30103⌋ + 2 = 6
  let int16_theoretical = (15.0 * log10_2).to_int() + 2
  inspect(int16_theoretical, content="6")
  inspect(Int16_Digits10 <= int16_theoretical, content="true")
}

///|
fn init {
  // Prevent unused constant warnings
  ignore([
    Byte_Digits10,
    UInt16_Digits10,
    Int16_Digits10,
    UInt_Digits10,
    Int_Digits10,
    UInt64_Digits10,
    Int64_Digits10,
    Byte_Digits,
    UInt16_Digits,
    Int16_Digits,
    UInt_Digits,
    Int_Digits,
    Int64_Digits,
    UInt64_Digits,
  ])
}
