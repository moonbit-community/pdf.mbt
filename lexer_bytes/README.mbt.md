# bytes_conv

A MoonBit library for parsing various data types from `BytesView`, providing efficient conversion functionality for integers, decimals, booleans and other data types with support for multiple numeric bases and comprehensive error handling.

## Quick Start

```moonbit
///|
test "basic usage" {
  // Parse integers from bytes
  let (num, advance_len) = @lexer_bytes.tokenize_int(b"42")
  @json.inspect(num, content=42)
  @json.inspect(advance_len, content=2)

  // Parse with different bases
  let (hex, advance_len) = @lexer_bytes.tokenize_int(b"ff", base=16)
  @json.inspect(hex, content=255)
  @json.inspect(advance_len, content=2)

  // Parse booleans
  let (flag, advance_len) = @lexer_bytes.tokenize_bool(b"true")
  @json.inspect(flag, content=true)
  @json.inspect(advance_len, content=4)
}
```

## Error Handling

All parsing functions can raise `StrConvError` when the input cannot be parsed:

```moonbit
///|
test "error handling" {
  // Using try? to get Result type
  let result = try? @lexer_bytes.tokenize_int(b"invalid")
  match result {
    Ok(_) =>
      @json.inspect("Should not reach here", content="Should not reach here")
    Err(@lexer_bytes.LexError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
  }

  // Handle specific errors
  let safe_result = @lexer_bytes.tokenize_double(b"not_a_number") catch {
    @lexer_bytes.LexError(msg) => {
      @json.inspect(msg, content="invalid syntax")
      (0.0, 0)
    }
  }
  let (val, _) = safe_result
  @json.inspect(val, content=0.0)
}
```

## Integer Parsing

### tokenize_int

Parse integers from `BytesView` with optional base specification:

```moonbit
///|
test "tokenize_int examples" {
  // Default base 10
  let (val1, advance_len) = @lexer_bytes.tokenize_int(b"123")
  @json.inspect(val1, content=123)
  @json.inspect(advance_len, content=3)
  let (val2, advance_len) = @lexer_bytes.tokenize_int(b"-456")
  @json.inspect(val2, content=-456)
  @json.inspect(advance_len, content=4)

  // Different bases
  let (val3, advance_len) = @lexer_bytes.tokenize_int(b"ff", base=16)
  @json.inspect(val3, content=255)
  @json.inspect(advance_len, content=2)
  let (val4, advance_len) = @lexer_bytes.tokenize_int(b"1010", base=2)
  @json.inspect(val4, content=10)
  @json.inspect(advance_len, content=4)
  let (val5, advance_len) = @lexer_bytes.tokenize_int(b"77", base=8)
  @json.inspect(val5, content=63)
  @json.inspect(advance_len, content=2)

  // Edge cases
  let (val6, advance_len) = @lexer_bytes.tokenize_int(b"0")
  @json.inspect(val6, content=0)
  @json.inspect(advance_len, content=1)
  let (val7, advance_len) = @lexer_bytes.tokenize_int(b"+42")
  @json.inspect(val7, content=42)
  @json.inspect(advance_len, content=3)
}
```

### tokenize_int64

Parse 64-bit integers from `BytesView`:

```moonbit
///|
test "tokenize_int64 examples" {
  let (val1, advance_len) = @lexer_bytes.tokenize_int64(b"9223372036854775807")
  inspect(val1, content="9223372036854775807")
  inspect(advance_len, content="19")
  let (val2, advance_len) = @lexer_bytes.tokenize_int64(b"-9223372036854775808")
  inspect(val2, content="-9223372036854775808")
  inspect(advance_len, content="20")

  // With different bases
  let (val3, advance_len) = @lexer_bytes.tokenize_int64(b"deadbeef", base=16)
  inspect(val3, content="3735928559")
  inspect(advance_len, content="8")
  let (val4, advance_len) = @lexer_bytes.tokenize_int64(
    b"1111000011110000",
    base=2,
  )
  inspect(val4, content="61680")
  inspect(advance_len, content="16")
}
```

### tokenize_uint

Parse unsigned integers from `BytesView`:

```moonbit
///|
test "tokenize_uint examples" {
  let (val1, advance_len) = @lexer_bytes.tokenize_uint(b"4294967295")
  inspect(val1, content="4294967295")
  inspect(advance_len, content="10")
  let (val2, advance_len) = @lexer_bytes.tokenize_uint(b"0")
  inspect(val2, content="0")
  inspect(advance_len, content="1")

  // With different bases
  let (val3, advance_len) = @lexer_bytes.tokenize_uint(b"ffffffff", base=16)
  inspect(val3, content="4294967295")
  inspect(advance_len, content="8")
  let (val4, advance_len) = @lexer_bytes.tokenize_uint(b"377", base=8)
  inspect(val4, content="255")
  inspect(advance_len, content="3")
}
```

### tokenize_uint64

Parse 64-bit unsigned integers from `BytesView`:

```moonbit
///|
test "tokenize_uint64 examples" {
  let (val1, _) = @lexer_bytes.tokenize_uint64(b"18446744073709551615")
  inspect(val1, content="18446744073709551615")
  let (val2, _) = @lexer_bytes.tokenize_uint64(b"0")
  inspect(val2, content="0")

  // With different bases
  let (val3, _) = @lexer_bytes.tokenize_uint64(b"ffffffffffffffff", base=16)
  inspect(val3, content="18446744073709551615")
}
```

## Floating Point Parsing

### tokenize_double

Parse double-precision floating point numbers from `BytesView`:

```moonbit
///|
test "tokenize_double examples" {
  let (val1, _) = @lexer_bytes.tokenize_double(b"3.14159")
  @json.inspect(val1, content=3.14159)
  let (val2, _) = @lexer_bytes.tokenize_double(b"-2.718")
  @json.inspect(val2, content=-2.718)
  let (val3, _) = @lexer_bytes.tokenize_double(b"0.0")
  @json.inspect(val3, content=0.0)

  // Scientific notation
  let (val4, _) = @lexer_bytes.tokenize_double(b"1.5e10")
  @json.inspect(val4, content=15000000000.0)
  let (val5, _) = @lexer_bytes.tokenize_double(b"2.5e-3")
  @json.inspect(val5, content=0.0025)

  // Special values  
  let (inf_val, _) = @lexer_bytes.tokenize_double(b"inf")
  let (neg_inf_val, _) = @lexer_bytes.tokenize_double(b"-inf")
  inspect(inf_val > 0.0 && inf_val.is_inf(), content="true")
  inspect(neg_inf_val < 0.0 && neg_inf_val.is_inf(), content="true")
}
```

## Boolean Parsing

### tokenize_bool

Parse boolean values from `BytesView`:

```moonbit
///|
test "tokenize_bool examples" {
  // True values
  let (val1, _) = @lexer_bytes.tokenize_bool(b"true")
  @json.inspect(val1, content=true)
  let (val2, _) = @lexer_bytes.tokenize_bool(b"True")
  @json.inspect(val2, content=true)
  let (val3, _) = @lexer_bytes.tokenize_bool(b"TRUE")
  @json.inspect(val3, content=true)
  let (val4, _) = @lexer_bytes.tokenize_bool(b"1")
  @json.inspect(val4, content=true)

  // False values
  let (val5, _) = @lexer_bytes.tokenize_bool(b"false")
  @json.inspect(val5, content=false)
  let (val6, _) = @lexer_bytes.tokenize_bool(b"False")
  @json.inspect(val6, content=false)
  let (val7, _) = @lexer_bytes.tokenize_bool(b"FALSE")
  @json.inspect(val7, content=false)
  let (val8, _) = @lexer_bytes.tokenize_bool(b"0")
  @json.inspect(val8, content=false)
}
```

## Generic Parsing

### parse

Generic parsing function that works with any type implementing `FromBytesView`:

```moonbit
///|
test "generic parse examples" {
  // Parse integers
  let (int_val, _) : (Int, Int) = @lexer_bytes.tokenize(b"42")
  @json.inspect(int_val, content=42)

  // Parse doubles
  let (double_val, _) : (Double, Int) = @lexer_bytes.tokenize(b"3.14")
  @json.inspect(double_val, content=3.14)

  // Parse booleans  
  let (bool_val, _) : (Bool, Int) = @lexer_bytes.tokenize(b"true")
  @json.inspect(bool_val, content=true)

  // Parse unsigned integers
  let (uint_val, _) : (UInt, Int) = @lexer_bytes.tokenize(b"123")
  inspect(uint_val, content="123")
}
```

## FromBytesView Trait

The `FromBytesView` trait enables types to be parsed from `BytesView`. Built-in implementations are provided for:

- `Bool`
- `Int` 
- `Int64`
- `UInt`
- `UInt64`
- `Double`

```moonbit
///|
test "trait usage examples" {
  // Using trait methods directly
  let (int_val, _) : (Int, Int) = @lexer_bytes.FromBytesView::from(b"100")
  @json.inspect(int_val, content=100)
  let (bool_val, _) : (Bool, Int) = @lexer_bytes.FromBytesView::from(b"false")
  @json.inspect(bool_val, content=false)
  let (double_val, _) : (Double, Int) = @lexer_bytes.FromBytesView::from(
    b"2.718",
  )
  @json.inspect(double_val, content=2.718)
}
```

## Error Types

### StrConvError

All parsing functions can raise `StrConvError` when conversion fails:

```moonbit
///|
test "error examples" {
  // Integer parsing errors
  let int_err = try? @lexer_bytes.tokenize_int(b"abc")
  match int_err {
    Err(@lexer_bytes.LexError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Double parsing errors  
  let double_err = try? @lexer_bytes.tokenize_double(b"not_a_number")
  match double_err {
    Err(@lexer_bytes.LexError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }

  // Boolean parsing errors
  let bool_err = try? @lexer_bytes.tokenize_bool(b"maybe")
  match bool_err {
    Err(@lexer_bytes.LexError(msg)) =>
      @json.inspect(msg, content="invalid syntax")
    _ => @json.inspect("unexpected", content="unexpected")
  }
}
```

## Advanced Usage

### Working with BytesView

```moonbit
///|
test "bytesview usage" {
  // Work with individual BytesViews
  let part1 = b"123"
  let part2 = b"456"
  let part3 = b"789"

  // Parse each part individually
  let (num1, _) = @lexer_bytes.tokenize_int(part1)
  let (num2, _) = @lexer_bytes.tokenize_int(part2)
  let (num3, _) = @lexer_bytes.tokenize_int(part3)
  inspect([num1, num2, num3], content="[123, 456, 789]")
}
```

### Base Conversion Examples

```moonbit
///|
test "base conversion showcase" {
  let binary = b"11010110"
  let octal = b"326"
  let decimal = b"214"
  let hex = b"d6"

  // All represent the same number (214 in decimal)
  let (val1, _) = @lexer_bytes.tokenize_int(binary, base=2)
  @json.inspect(val1, content=214)
  let (val2, _) = @lexer_bytes.tokenize_int(octal, base=8)
  @json.inspect(val2, content=214)
  let (val3, _) = @lexer_bytes.tokenize_int(decimal, base=10)
  @json.inspect(val3, content=214)
  let (val4, _) = @lexer_bytes.tokenize_int(hex, base=16)
  @json.inspect(val4, content=214)
}
```
















































