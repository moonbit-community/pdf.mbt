///|
/// A lexer for PDF objects.
pub fn tokenize(input : BytesView) -> Array[(Token, Position, Position)] {
  let mut input = input
  let mut start_row = 0
  let mut start_col = 0
  let mut row = 0
  let mut col = 0
  let result = []
  fn push(tok : Token, length : Int) -> Unit {
    let start = Position::{ row: start_row, col: start_col }
    col += length
    let end = Position::{ row, col }
    result.push((tok, start, end))
    start_row = row
    start_col = col
  }

  fn push_no_token(length : Int) -> Unit {
    col += length
    start_row = row
    start_col = col
  }

  for ;; {
    if input.is_empty() {
      push(EOF, 0)
      break
    }

    let whitespace_length = scan_pdf_object_whitespace(input)
    if whitespace_length > 0 {
      push_no_token(whitespace_length)
      input = input[whitespace_length:]
      continue
    }

    match pdf_eol_length(input) {
      Some(eol_length) => {
        row += 1
        col = 0
        start_row = row
        start_col = 0
        input = input[eol_length:]
        continue
      }
      None => ()
    }

    if input[0] == b'%' {
      let mut comment_end = 1
      while comment_end < input.length() &&
            input[comment_end] != b'\r' &&
            input[comment_end] != b'\n' {
        comment_end += 1
      }
      if comment_end < input.length() {
        guard pdf_eol_length(input[comment_end:]) is Some(eol_length) else {
          panic()
        }
        row += 1
        col = 0
        start_row = row
        start_col = 0
        input = input[comment_end + eol_length:]
      } else {
        input = input[comment_end:]
      }
      continue
    }

    if input.has_prefix(b"<<") {
      push(DICT_BEGIN, 2)
      input = input[2:]
      continue
    }
    if input.has_prefix(b">>") {
      push(DICT_END, 2)
      input = input[2:]
      continue
    }
    if input.has_prefix(b"true") {
      push(TRUE, 4)
      input = input[4:]
      continue
    }
    if input.has_prefix(b"false") {
      push(FALSE, 5)
      input = input[5:]
      continue
    }
    if input.has_prefix(b"null") {
      push(NULL, 4)
      input = input[4:]
      continue
    }

    let indirect_length = scan_pdf_indirect(input)
    let real_length = scan_pdf_real(input)
    let integer_length = scan_pdf_integer(input)
    if indirect_length > real_length && indirect_length > integer_length {
      let indirect = tokenize_pdf_indirect(input[:indirect_length])
      push(INDIRECT(indirect), indirect_length)
      input = input[indirect_length:]
      continue
    }
    if real_length > 0 && real_length >= integer_length {
      let (value, _) = try! @lexer_bytes.tokenize_double(input[:real_length])
      push(REAL(value), real_length)
      input = input[real_length:]
      continue
    }
    if integer_length > 0 {
      let (value, _) = try! @lexer_bytes.tokenize_int(input[:integer_length])
      push(INTEGER(value), integer_length)
      input = input[integer_length:]
      continue
    }

    if input.has_prefix(b"stream") {
      let rest = input[b"stream".length():]
      let mut stream_input = rest
      if stream_input.length() > 0 {
        if stream_input.length() >= 2 &&
          stream_input[0] == b'\r' &&
          stream_input[1] == b'\n' {
          stream_input = stream_input[2:]
          col += 2
          row += 1
          col = 0
        } else if stream_input[0] == b'\r' || stream_input[0] == b'\n' {
          stream_input = stream_input[1:]
          col += 1
          row += 1
          col = 0
        }
      }
      let mut end_pos = 0
      let mut found_endstream = false
      let endstream_bytes = b"endstream"
      while end_pos <= stream_input.length() - endstream_bytes.length() {
        let mut matches = true
        for i in 0..<endstream_bytes.length() {
          if stream_input[end_pos + i] != endstream_bytes[i] {
            matches = false
            break
          }
        }
        if matches {
          found_endstream = true
          break
        }
        end_pos += 1
      }
      if found_endstream {
        let stream_data = stream_input[:end_pos].to_owned()
        push(
          STREAM_BYTES(stream_data),
          b"stream".length() + (rest.length() - stream_input.length()) + end_pos,
        )
        input = stream_input[end_pos + endstream_bytes.length():]
      } else {
        push(STREAM_BYTES(b""), b"stream".length())
        input = rest
      }
      continue
    }

    match input[0] {
      b'/' => {
        let rest = input[1:]
        let (value, offset) = tokenize_pdf_name(rest)
        let total_length = 1 + offset
        let full_name = Bytes::from_array([b'/']) + value
        push(NAME(full_name), total_length)
        input = rest[offset:]
      }
      b'(' => {
        let rest = input[1:]
        let (value, length) = tokenize_pdf_literal_string(rest)
        push(STRING(value), length)
        input = rest[length:]
      }
      b')' => {
        push(RIGHT_PARENTHESIS, 1)
        input = input[1:]
      }
      b'{' => {
        push(LEFT_CURLY_BRACE, 1)
        input = input[1:]
      }
      b'}' => {
        push(RIGHT_CURLY_BRACE, 1)
        input = input[1:]
      }
      b'[' => {
        push(LEFT_SQUARE_BRACKET, 1)
        input = input[1:]
      }
      b']' => {
        push(RIGHT_SQUARE_BRACKET, 1)
        input = input[1:]
      }
      b'<' => {
        let string_length = scan_pdf_hex_string(input)
        if string_length > 0 {
          let value = tokenize_pdf_hexadecimal_string(
            input[1:string_length - 1],
          )
          push(STRING(value), string_length)
          input = input[string_length:]
        } else {
          push(LESS_THAN_SIGN, 1)
          input = input[1:]
        }
      }
      b'>' => {
        push(GREATER_THAN_SIGN, 1)
        input = input[1:]
      }
      _ => {
        col += 1
        start_row = row
        start_col = col
        input = input[1:]
      }
    }
  }
  result
}

///|
pub fn tokenize_pdf_literal_string(input : BytesView) -> (Bytes, Int) {
  let buffer = Buffer(size_hint=input.length())
  let mut offset = 0
  for input = input {
    match input {
      // Escape sequences
      [b'\\', b'n', .. rest] => {
        buffer.write_byte(b'\n')
        offset += 2
        continue rest
      }
      [b'\\', b'r', .. rest] => {
        buffer.write_byte(b'\r')
        offset += 2
        continue rest
      }
      [b'\\', b't', .. rest] => {
        buffer.write_byte(b'\t')
        offset += 2
        continue rest
      }
      [b'\\', b'b', .. rest] => {
        buffer.write_byte(b'\b')
        offset += 2
        continue rest
      }
      [b'\\', b'f', .. rest] => {
        buffer.write_byte(b'\x0c') // form feed
        offset += 2
        continue rest
      }
      [b'\\', b'\\', .. rest] => {
        buffer.write_byte(b'\\')
        offset += 2
        continue rest
      }
      [b'\\', b'(', .. rest] => {
        buffer.write_byte(b'(')
        offset += 2
        continue rest
      }
      [b'\\', b')', .. rest] => {
        buffer.write_byte(b')')
        offset += 2
        continue rest
      }
      // Multi-line string handling: backslash followed by end-of-line marker is ignored
      [b'\\', b'\r', b'\n', .. rest] => {
        // Backslash followed by CRLF - ignore both the backslash and the end-of-line
        offset += 3
        continue rest
      }
      [b'\\', b'\r', .. rest] => {
        // Backslash followed by CR - ignore both
        offset += 2
        continue rest
      }
      [b'\\', b'\n', .. rest] => {
        // Backslash followed by LF - ignore both
        offset += 2
        continue rest
      }
      // Octal escape sequences: \ddd where d is 0-7
      [b'\\', d1, d2, d3, .. rest] if d1 >= b'0' &&
        d1 <= b'7' &&
        d2 >= b'0' &&
        d2 <= b'7' &&
        d3 >= b'0' &&
        d3 <= b'7' => {
        let octal_value = (d1.to_int() - '0'.to_int()) * 64 +
          (d2.to_int() - '0'.to_int()) * 8 +
          (d3.to_int() - '0'.to_int())
        buffer.write_byte(octal_value.to_byte())
        offset += 4
        continue rest
      }
      // Two-digit octal escape sequences: \dd
      [b'\\', d1, d2, .. rest] if d1 >= b'0' &&
        d1 <= b'7' &&
        d2 >= b'0' &&
        d2 <= b'7' => {
        let octal_value = (d1.to_int() - '0'.to_int()) * 8 +
          (d2.to_int() - '0'.to_int())
        buffer.write_byte(octal_value.to_byte())
        offset += 3
        continue rest
      }
      // One-digit octal escape sequences: \d
      [b'\\', d1, .. rest] if d1 >= b'0' && d1 <= b'7' => {
        let octal_value = d1.to_int() - '0'.to_int()
        buffer.write_byte(octal_value.to_byte())
        offset += 2
        continue rest
      }
      // Unrecognized escape sequence - ignore the backslash
      [b'\\', _, .. rest] => {
        offset += 2
        continue rest
      }
      // End-of-line markers in string literals are converted to \n
      [b'\r', b'\n', .. rest] => {
        buffer.write_byte(b'\n')
        offset += 2
        continue rest
      }
      [b'\r', .. rest] => {
        buffer.write_byte(b'\n')
        offset += 1
        continue rest
      }
      [b'\n', .. rest] => {
        buffer.write_byte(b'\n')
        offset += 1
        continue rest
      }
      // Close delimiter: early return when encountering ')'
      [b')', .. _rest] =>
        // Return immediately when we encounter the closing parenthesis
        // offset + 1 to include the ')' character in the advance offset
        break (buffer.to_bytes(), offset + 1)
      [
        // Regular characters
        c,
        .. rest,
      ] => {
        buffer.write_byte(c.to_int().to_byte())
        offset += 1
        continue rest
      }
      // End of input without finding closing ')'
      [] => break (buffer.to_bytes(), offset)
    }
  }
}

///|
/// 1. whitespace is ignored
/// 2. missing second hex digit is treated as if followed by 0
pub fn tokenize_pdf_hexadecimal_string(input : BytesView) -> Bytes {
  let output = []
  let mut pending_digit : Int? = None
  for input = input {
    match input {
      // Skip whitespace characters (space, tab, CR, LF)
      [b' ', .. rest]
      | [b'\t', .. rest]
      | [b'\r', .. rest]
      | [b'\n', .. rest] => continue rest

      // Process hex digits
      [b, .. rest] =>
        match hex_byte_to_value(b) {
          Some(digit) =>
            match pending_digit {
              None => {
                // First digit of a pair
                pending_digit = Some(digit)
                continue rest
              }
              Some(first_digit) => {
                // Second digit of a pair - combine into byte
                let byte_value = first_digit * 16 + digit
                output.push(byte_value.to_byte())
                pending_digit = None
                continue rest
              }
            }
          None =>
            // Non-hex character, skip it (could be part of malformed input)
            continue rest
        }
      [] => {
        // End of input
        // Handle odd number of hex digits by treating last digit as if followed by 0
        match pending_digit {
          Some(digit) => {
            let byte_value = digit * 16 // digit followed by 0
            output.push(byte_value.to_byte())
          }
          None => ()
        }
        break Bytes::from_array(output)
      }
    }
  }
}

///|
/// 
/// 1. ASCII printable character 
/// 2. ASCII non-printable character (0-31) must be escaped as #XX
/// 
/// This function excludes the leading `/` character from PDF names
/// 
pub fn tokenize_pdf_name(input : BytesView) -> (Bytes, Int) {
  let buffer = Buffer(size_hint=input.length())
  let mut offset = 0
  for input = input[offset:] {
    match input {
      // Handle escape sequences (#XX)
      [b'#', h1, h2, .. rest] =>
        match (hex_byte_to_value(h1), hex_byte_to_value(h2)) {
          (Some(v1), Some(v2)) => {
            let byte_value = v1 * 16 + v2
            buffer.write_byte(byte_value.to_byte())
            offset += 3
            continue rest
          }
          _ => {
            // Invalid hex sequence, treat # as literal character
            buffer.write_byte(b'#')
            offset += 1
            continue [h1, h2, ..rest]
          }
        }

      // Handle incomplete escape sequence at end
      [b'#', h1, .. rest] =>
        match hex_byte_to_value(h1) {
          Some(v1) => {
            // Incomplete hex sequence, treat as if followed by 0
            let byte_value = v1 * 16
            buffer.write_byte(byte_value.to_byte())
            offset += 2
            continue rest
          }
          _ => {
            // Invalid hex character, treat # as literal
            buffer.write_byte(b'#')
            offset += 1
            continue [h1, ..rest]
          }
        }

      // Handle lone # at end
      [b'#'] => {
        buffer.write_byte(b'#')
        offset += 1
        break (buffer.to_bytes(), offset)
      }

      // PDF name delimiters - stop parsing when encountered
      [b' ', ..]
      | [b'\t', ..]
      | [b'\r', ..]
      | [b'\n', ..]
      | [b'\f', ..]
      | [b'\x00', ..] =>
        // Whitespace characters end the name
        break (buffer.to_bytes(), offset)
      [b'(', ..]
      | [b')', ..]
      | [b'<', ..]
      | [b'>', ..]
      | [b'[', ..]
      | [b']', ..]
      | [b'{', ..]
      | [b'}', ..] =>
        // Delimiter characters end the name
        break (buffer.to_bytes(), offset)
      [b'/', ..] =>
        // Solidus (forward slash) ends the name
        break (buffer.to_bytes(), offset)
      [b'%', ..] =>
        // Comment start ends the name
        break (buffer.to_bytes(), offset)
      [

        // Regular characters - continue building the name
        c,
        .. rest,
      ] => {
        buffer.write_byte(c)
        offset += 1
        continue rest
      }

      // End of input
      [] => break (buffer.to_bytes(), offset)
    }
  }
}

///|
fn hex_byte_to_value(c : Byte) -> Int? {
  match c {
    b'0'..=b'9' => Some(c.to_int() - b'0'.to_int())
    b'A'..=b'F' => Some(c.to_int() - b'A'.to_int() + 10)
    b'a'..=b'f' => Some(c.to_int() - b'a'.to_int() + 10)
    _ => None
  }
}

///|
/// Parse PDF indirect object reference of the form "obj_num gen_num R"
/// Example: "123 0 R" -> INDIRECT { object_num: 123, generation_num: 0 }
fn tokenize_pdf_indirect(input : BytesView) -> INDIRECT {
  // Split the input by whitespace and extract the numbers
  let mut object_num = 0
  let mut generation_num = 0
  let mut current_number = 0
  let mut parsing_first = true
  let mut parsing_number = false
  for input = input {
    match input {
      // Skip whitespace and find numbers
      [b' ', .. rest] | [b'\t', .. rest] => {
        if parsing_number {
          // Finished parsing a number
          if parsing_first {
            object_num = current_number
            parsing_first = false
          } else {
            generation_num = current_number
            break // We have both numbers, ignore the rest (should be 'R')
          }
          current_number = 0
          parsing_number = false
        }
        continue rest
      }

      // Parse digit characters
      [b'0'..=b'9' as digit, .. rest] => {
        parsing_number = true
        current_number = current_number * 10 + (digit.to_int() - b'0'.to_int())
        continue rest
      }

      // Skip 'R' character and any other characters
      [_, .. rest] => {
        if parsing_number {
          // Finished parsing a number
          if parsing_first {
            object_num = current_number
            parsing_first = false
          } else {
            generation_num = current_number
            break // We have both numbers
          }
          current_number = 0
          parsing_number = false
        }
        continue rest
      }

      // End of input
      [] => {
        if parsing_number {
          if parsing_first {
            object_num = current_number
          } else {
            generation_num = current_number
          }
        }
        break
      }
    }
  }
  { object_num, generation_num }
}
