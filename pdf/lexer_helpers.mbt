///|
fn is_ascii_digit(byte : Byte) -> Bool {
  byte >= b'0' && byte <= b'9'
}

///|
fn scan_ascii_digits(input : BytesView, start : Int) -> Int {
  let length = input.length()
  for end = start; end < length; end = end + 1 {
    if !is_ascii_digit(input[end]) {
      return end
    }
  }
  length
}

///|
fn scan_byte(input : BytesView, start : Int, byte : Byte) -> Int {
  let length = input.length()
  for end = start; end < length; end = end + 1 {
    if input[end] != byte {
      return end
    }
  }
  length
}

///|
fn pdf_eol_length(input : BytesView) -> Int? {
  match input {
    [b'\r', b'\n', ..] => Some(2)
    [b'\r', ..] | [b'\n', ..] => Some(1)
    _ => None
  }
}

///|
fn xref_eol_length(input : BytesView) -> Int? {
  match input {
    [b' ', b'\r', ..] | [b' ', b'\n', ..] => Some(2)
    _ => pdf_eol_length(input)
  }
}

///|
fn starts_with_at(input : BytesView, start : Int, prefix : BytesView) -> Bool {
  start >= 0 &&
  start + prefix.length() <= input.length() &&
  input[start:start + prefix.length()] == prefix
}

///|
fn scan_pdf_object_whitespace(input : BytesView) -> Int {
  for end = 0; end < input.length(); end = end + 1 {
    match input[end] {
      b' ' | b'\t' | b'\f' | b'\x00' => ()
      _ => return end
    }
  }
  input.length()
}

///|
fn scan_exponent(input : BytesView, start : Int) -> Int {
  if start >= input.length() || (input[start] != b'e' && input[start] != b'E') {
    return start
  }
  let mut digits_start = start + 1
  if digits_start < input.length() &&
    (input[digits_start] == b'+' || input[digits_start] == b'-') {
    digits_start += 1
  }
  let end = scan_ascii_digits(input, digits_start)
  if end == digits_start {
    start
  } else {
    end
  }
}

///|
fn scan_pdf_real(input : BytesView) -> Int {
  let mut start = 0
  if input is [b'-', ..] {
    start = 1
  }
  if start >= input.length() {
    return 0
  }
  if is_ascii_digit(input[start]) {
    let integer_end = scan_ascii_digits(input, start)
    if integer_end < input.length() && input[integer_end] == b'.' {
      let fraction_end = scan_ascii_digits(input, integer_end + 1)
      return scan_exponent(input, fraction_end)
    }
    let exponent_end = scan_exponent(input, integer_end)
    if exponent_end > integer_end {
      exponent_end
    } else {
      0
    }
  } else if input[start] == b'.' {
    let fraction_start = start + 1
    let fraction_end = scan_ascii_digits(input, fraction_start)
    if fraction_end == fraction_start {
      0
    } else {
      scan_exponent(input, fraction_end)
    }
  } else {
    0
  }
}

///|
fn scan_pdf_integer(input : BytesView) -> Int {
  let mut start = 0
  if input is [b'-', ..] {
    start = 1
  }
  if start >= input.length() {
    return 0
  }
  match input[start] {
    b'1'..=b'9' => scan_ascii_digits(input, start)
    b'0' => {
      let after_zero = start + 1
      if after_zero + 1 < input.length() &&
        (input[after_zero] == b'x' || input[after_zero] == b'X') &&
        hex_byte_to_value(input[after_zero + 1]) is Some(_) {
        for end = after_zero + 2; end < input.length(); end = end + 1 {
          if hex_byte_to_value(input[end]) is None {
            return end
          }
        }
        input.length()
      } else {
        for end = after_zero; end < input.length(); end = end + 1 {
          if input[end] < b'0' || input[end] > b'7' {
            return end
          }
        }
        input.length()
      }
    }
    _ => 0
  }
}

///|
fn scan_pdf_indirect(input : BytesView) -> Int {
  let object_end = scan_ascii_digits(input, 0)
  if object_end == 0 {
    return 0
  }
  let mut generation_start = object_end
  while generation_start < input.length() &&
        (input[generation_start] == b' ' || input[generation_start] == b'\t') {
    generation_start += 1
  }
  if generation_start == object_end {
    return 0
  }
  let generation_end = scan_ascii_digits(input, generation_start)
  if generation_end == generation_start {
    return 0
  }
  let mut marker = generation_end
  while marker < input.length() &&
        (input[marker] == b' ' || input[marker] == b'\t') {
    marker += 1
  }
  if marker == generation_end ||
    marker >= input.length() ||
    input[marker] != b'R' {
    0
  } else {
    marker + 1
  }
}

///|
fn scan_pdf_hex_string(input : BytesView) -> Int {
  guard input is [b'<', ..] else { return 0 }
  for end = 1; end < input.length(); end = end + 1 {
    match input[end] {
      b'>' => return end + 1
      b' ' | b'\t' | b'\r' | b'\n' => ()
      byte => if hex_byte_to_value(byte) is None { return 0 }
    }
  }
  0
}
