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

  for {
    lexmatch input with longest {
      // Whitespace (spaces, tabs, form feed, null character)
      ("[ \t\f\0]+" as s, rest) => {
        push_no_token(s.length())
        input = rest
      }

      // Newlines (CR, LF, CRLF)
      ("(\r\n)|\r|\n", rest) => {
        row += 1
        col = 0
        start_row = row
        start_col = 0
        input = rest
      }

      // PDF Comments (% until end of line, including the end-of-line marker)
      // Handles all three PDF end-of-line markers: \r\n, \r, \n
      ("%[^\r\n]*(\r\n|\r|\n)", rest) => {
        // Comments are ignored, advance to next line
        row += 1
        col = 0
        start_row = row
        start_col = 0
        input = rest
      }

      // PDF Comments at end of file (% until end of input without end-of-line)
      // WARNING: This pattern is NOT redundant with the above pattern!
      // The above pattern requires a newline after the comment: "%[^\r\n]*(\r\n|\r|\n)"
      // This pattern handles comments at EOF WITHOUT trailing newlines: "%[^\r\n]*$"
      // Example: "true % comment" (comment at end with no newline)
      ("%[^\r\n]*$", rest) =>
        // Comment at end of file, just advance position
        input = rest

      // Dictionary delimiters (must come before < and >)
      ("<<", rest) => {
        push(DICT_BEGIN, 2)
        input = rest
      }
      (">>", rest) => {
        push(DICT_END, 2)
        input = rest
      }

      // Boolean literals (must come before general identifiers)
      ("true", rest) => {
        push(TRUE, 4)
        input = rest
      }
      ("false", rest) => {
        push(FALSE, 5)
        input = rest
      }
      ("null", rest) => {
        push(NULL, 4)
        input = rest
      }

      // Real numbers (must come before integers to catch decimals)
      // Matches: 123.456, .456, 123., 123.456E10, 123E-5, -123.456, +123.456
      (
        "-?(([0-9]+\.[0-9]*|\.[0-9]+)([eE][+\-]?[0-9]+)?|[0-9]+[eE][+\-]?[0-9]+)" as s,
        rest
      ) => {
        let (value, _) = try! @lexer_bytes.tokenize_double(s)
        push(REAL(value), s.length())
        input = rest
      }

      // Integers (positive, negative, decimal, octal, hex)
      ("-?([1-9][0-9]*|0[xX][0-9a-fA-F]+|0[0-7]*)" as s, rest) => {
        let (value, _) = try! @lexer_bytes.tokenize_int(s)
        push(INTEGER(value), s.length())
        input = rest
      }

      // PDF Names: /Name (starts with solidus)
      ("/" as s, rest) => {
        let (value, offset) = tokenize_pdf_name(rest)
        let total_length = 1 + offset // 1 for the '/' + offset for the name
        let full_name = Bytes::from_array([b'/']) + value
        push(NAME(full_name), total_length)
        input = rest[offset:]
      }

      // Literal strings: (text with possible escape sequences)
      // For now, use a simple approach and handle more complex cases later
      ("\(" as s, rest) => {
        let (value, length) = tokenize_pdf_literal_string(rest) // Exclude the surrounding parentheses
        push(STRING(value), length)
        input = rest[length:]
      }

      // Single character delimiters
      ("\(", rest) => {
        push(LEFT_PARENTHESIS, 1)
        input = rest
      }
      ("\)", rest) => {
        push(RIGHT_PARENTHESIS, 1)
        input = rest
      }
      ("[{]", rest) => {
        push(LEFT_CURLY_BRACE, 1)
        input = rest
      }
      ("[}]", rest) => {
        push(RIGHT_CURLY_BRACE, 1)
        input = rest
      }
      ("\[", rest) => {
        push(LEFT_SQUARE_BRACKET, 1)
        input = rest
      }
      ("\]", rest) => {
        push(RIGHT_SQUARE_BRACKET, 1)
        input = rest
      }

      // Hexadecimal strings: <hex digits and whitespace>
      ("<[0-9a-fA-F \t\r\n]*>" as s, rest) => {
        let value = tokenize_pdf_hexadecimal_string(s[1:s.length() - 1]) // Exclude the surrounding angle brackets
        push(STRING(value), s.length())
        input = rest
      }
      ("<", rest) => {
        push(LESS_THAN_SIGN, 1)
        input = rest
      }
      (">", rest) => {
        push(GREATER_THAN_SIGN, 1)
        input = rest
      }
      ("/", rest) => {
        push(SOLIDUS, 1)
        input = rest
      }
      ("\d+[ \t]+\d+[ \t]+R" as s, rest) => {
        let indirect = tokenize_pdf_indirect(s)
        push(INDIRECT(indirect), s.length())
        input = rest
      }
      ("stream", rest) => {
        // Manual non-greedy match for stream data: `stream` `.*?` `endstream`
        let mut stream_input = rest
        // Skip only the first EOL marker after "stream" (LF or CRLF)
        // According to PDF spec, stream keyword must be followed by LF or CRLF
        if stream_input.length() > 0 {
          if stream_input.length() >= 2 &&
            stream_input[0] == b'\r' &&
            stream_input[1] == b'\n' {
            // Handle CRLF
            stream_input = stream_input[2:]
            col += 2
            row += 1
            col = 0
          } else if stream_input[0] == b'\r' || stream_input[0] == b'\n' {
            // Handle CR or LF
            stream_input = stream_input[1:]
            col += 1
            row += 1
            col = 0
          }
          // Note: we don't skip any other whitespace or multiple EOLs
          // Everything else is part of the stream content
        }

        // Find "endstream" - non-greedy search
        // We need to find the first occurrence of "endstream" as a delimiter
        let mut end_pos = 0
        let mut found_endstream = false
        let endstream_bytes = b"endstream"
        while end_pos <= stream_input.length() - endstream_bytes.length() {
          // Check if we found "endstream" at current position
          let mut matches = true
          for i = 0; i < endstream_bytes.length(); i = i + 1 {
            if stream_input[end_pos + i] != endstream_bytes[i] {
              matches = false
              break
            }
          }
          if matches {
            // According to PDF spec, "endstream" is a keyword delimiter
            // It should be treated as a delimiter regardless of preceding character
            // However, we implement non-greedy matching by taking the first occurrence
            found_endstream = true
            break
          }
          end_pos += 1
        }
        if found_endstream {
          // Extract the stream data (between stream and endstream)
          let stream_data = stream_input[:end_pos].to_bytes()
          push(
            STREAM_BYTES(stream_data),
            6 + (rest.length() - stream_input.length()) + end_pos,
          )
          // Position input after "endstream"
          input = stream_input[end_pos + endstream_bytes.length():]
        } else {
          // If endstream not found, treat as stream with empty data
          push(STREAM_BYTES(b""), 6)
          input = rest
        }
      }

      // End of input
      ("$", rest) => {
        push(EOF, 0)
        break
      }

      // Any other character (skip unrecognized characters)
      _ => {
        // Skip one character and continue
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
  let buffer = @buffer.new(size_hint=input.length())
  let mut offset = 0
  loop input {
    // Escape sequences
    ['\\', 'n', .. rest] => {
      buffer.write_byte(b'\n')
      offset += 2
      continue rest
    }
    ['\\', 'r', .. rest] => {
      buffer.write_byte(b'\r')
      offset += 2
      continue rest
    }
    ['\\', 't', .. rest] => {
      buffer.write_byte(b'\t')
      offset += 2
      continue rest
    }
    ['\\', 'b', .. rest] => {
      buffer.write_byte(b'\b')
      offset += 2
      continue rest
    }
    ['\\', 'f', .. rest] => {
      buffer.write_byte(b'\x0c') // form feed
      offset += 2
      continue rest
    }
    ['\\', '\\', .. rest] => {
      buffer.write_byte(b'\\')
      offset += 2
      continue rest
    }
    ['\\', '(', .. rest] => {
      buffer.write_byte(b'(')
      offset += 2
      continue rest
    }
    ['\\', ')', .. rest] => {
      buffer.write_byte(b')')
      offset += 2
      continue rest
    }
    // Multi-line string handling: backslash followed by end-of-line marker is ignored
    ['\\', '\r', '\n', .. rest] => {
      // Backslash followed by CRLF - ignore both the backslash and the end-of-line
      offset += 3
      continue rest
    }
    ['\\', '\r', .. rest] => {
      // Backslash followed by CR - ignore both
      offset += 2
      continue rest
    }
    ['\\', '\n', .. rest] => {
      // Backslash followed by LF - ignore both
      offset += 2
      continue rest
    }
    // Octal escape sequences: \ddd where d is 0-7
    ['\\', d1, d2, d3, .. rest] if d1 >= '0' &&
      d1 <= '7' &&
      d2 >= '0' &&
      d2 <= '7' &&
      d3 >= '0' &&
      d3 <= '7' => {
      let octal_value = (d1.to_int() - '0'.to_int()) * 64 +
        (d2.to_int() - '0'.to_int()) * 8 +
        (d3.to_int() - '0'.to_int())
      buffer.write_byte(octal_value.to_byte())
      offset += 4
      continue rest
    }
    // Two-digit octal escape sequences: \dd
    ['\\', d1, d2, .. rest] if d1 >= '0' && d1 <= '7' && d2 >= '0' && d2 <= '7' => {
      let octal_value = (d1.to_int() - '0'.to_int()) * 8 +
        (d2.to_int() - '0'.to_int())
      buffer.write_byte(octal_value.to_byte())
      offset += 3
      continue rest
    }
    // One-digit octal escape sequences: \d
    ['\\', d1, .. rest] if d1 >= '0' && d1 <= '7' => {
      let octal_value = d1.to_int() - '0'.to_int()
      buffer.write_byte(octal_value.to_byte())
      offset += 2
      continue rest
    }
    // Unrecognized escape sequence - ignore the backslash
    ['\\', _, .. rest] => {
      offset += 2
      continue rest
    }
    // End-of-line markers in string literals are converted to \n
    ['\r', '\n', .. rest] => {
      buffer.write_byte(b'\n')
      offset += 2
      continue rest
    }
    ['\r', .. rest] => {
      buffer.write_byte(b'\n')
      offset += 1
      continue rest
    }
    ['\n', .. rest] => {
      buffer.write_byte(b'\n')
      offset += 1
      continue rest
    }
    // Close delimiter: early return when encountering ')'
    [')', .. _rest] =>
      // Return immediately when we encounter the closing parenthesis
      // offset + 1 to include the ')' character in the advance offset
      (buffer.to_bytes(), offset + 1)
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
    [] => (buffer.to_bytes(), offset)
  }
}

///|
/// 1. whitespace is ignored
/// 2. missing second hex digit is treated as if followed by 0
pub fn tokenize_pdf_hexadecimal_string(input : BytesView) -> Bytes {
  let output = []
  let mut pending_digit : Int? = None
  loop input {
    // Skip whitespace characters (space, tab, CR, LF)
    [b' ', .. rest] | [b'\t', .. rest] | [b'\r', .. rest] | [b'\n', .. rest] =>
      continue rest

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
      Bytes::from_array(output)
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
  let buffer = @buffer.new(size_hint=input.length())
  let mut offset = 0
  loop input[offset:] {
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
      (buffer.to_bytes(), offset)
    }

    // PDF name delimiters - stop parsing when encountered
    [b' ', ..]
    | [b'\t', ..]
    | [b'\r', ..]
    | [b'\n', ..]
    | [b'\f', ..]
    | [b'\x00', ..] =>
      // Whitespace characters end the name
      (buffer.to_bytes(), offset)
    [b'(', ..]
    | [b')', ..]
    | [b'<', ..]
    | [b'>', ..]
    | [b'[', ..]
    | [b']', ..]
    | [b'{', ..]
    | [b'}', ..] =>
      // Delimiter characters end the name
      (buffer.to_bytes(), offset)
    [b'/', ..] =>
      // Solidus (forward slash) ends the name
      (buffer.to_bytes(), offset)
    [b'%', ..] =>
      // Comment start ends the name
      (buffer.to_bytes(), offset)
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
    [] => (buffer.to_bytes(), offset)
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
  loop input {
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
  INDIRECT::{ object_num, generation_num }
}
