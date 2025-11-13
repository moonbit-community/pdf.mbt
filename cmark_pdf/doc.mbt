///|
fn Doc::remove_contiguous_blanklines(self : Doc) -> Doc {
  let result = []
  let mut last_was_blankline = false
  for block in self.0 {
    if block is BlankLine {
      if !last_was_blankline {
        result.push(block)
        last_was_blankline = true
      }
    } else {
      result.push(block)
      last_was_blankline = false
    }
  }
  Doc(result)
}

///|
pub fn Doc::from_cmark(doc : @cmark.Doc) -> Doc {
  match doc.block {
    Blocks(node) => {
      let seq = node.v
      let blocks = seq.to_array()
      blocks.map(Block::from_cmark)
    }
    _ => panic()
  }
}

///|
pub fn Doc::to_flatheadings(self : Doc) -> Array[FlatHeading] {
  let mut h1 = 0
  let mut h2 = 0
  let mut h3 = 0
  let result = []
  for block in self.0 {
    if block is Heading(level~, text~) {
      match level {
        1 => {
          h1 += 1
          h2 = 0
          h3 = 0
          result.push(FlatHeading::{ num: [h1], text })
        }
        2 => {
          h2 += 1
          h3 = 0
          result.push(FlatHeading::{ num: [h1, h2], text })
        }
        3 => {
          h3 += 1
          result.push(FlatHeading::{ num: [h1, h2, h3], text })
        }
        _ => {
          // For levels > 3, treat them as level 3 headings
          h3 += 1
          result.push(FlatHeading::{ num: [h1, h2, h3], text })
        }
      }
    }
  }
  result
}

///|
fn Doc::to_graphic_operators(self : Doc) -> ContentStream {
  let canvas = Canvas::new()
  for block in self.0 {
    Block::render_to_canvas(block, canvas)
  }
  canvas.to_content()
}

///|
fn Block::render_to_canvas(block : Block, canvas : Canvas) -> Unit {
  match block {
    Heading(level~, text~) => {
      let font_size = match level {
        1 => font_size_h1
        2 => font_size_h2
        3 => font_size_h3
        _ => font_size_body
      }
      canvas.set_font(b"/F0", font_size)
      canvas.show_text(pdf_bytes_of_string(text))
      canvas.set_leading(font_size)
      canvas.next_line()
    }
    Paragraph(para) => {
      canvas.set_leading(font_size_body)
      canvas.set_font(b"/F0", font_size_body)
      let max_cols = 80
      let mut cur_cols = 0
      for text in para {
        let (s, f) = match text {
          Plain(s) => (s, b"/F0")
          StrongEmphasis(s) => (s, b"/F1")
          Emphasis(s) => (s, b"/F2")
          StrongEmphasis_Emphasis(s) => (s, b"/F3")
          CodeSpan(s) => (s, b"/F4")
        }
        // FIXME: 
        // current behavior: if non-ASCII then use '?' replacement
        // expected behavior: correctly set the enoding in the PDF
        let s = pdf_bytes_of_string(s)
        let len = s.length()
        // set font and font size 
        canvas.set_font(f, font_size_body)
        if cur_cols + len > max_cols {
          // split text not exceeding max_cols
          let split_parts = split_bytes(s, init_cols=cur_cols, max_cols~)
          // Handle split parts with pattern matching
          match split_parts {
            [] => () // Should not happen, but handle gracefully
            [first, .. rest] => {
              canvas.show_text(first)
              for part in rest {
                canvas.next_line()
                canvas.show_text(part)
              }
            }
          }
          // Calculate remaining columns on the last line
          let last_part = split_parts[split_parts.length() - 1]
          cur_cols = last_part.length()
        } else {
          // directly show text 
          canvas.show_text(s)
          cur_cols += len
        }
      }
      canvas.next_line()
    }
    BlankLine => {
      canvas.set_leading(font_size_body)
      canvas.next_line()
    }
    CodeBlock(code~, ..) => {
      canvas.set_font(b"/F4", font_size_body)
      for col, line in code {
        canvas.set_leading(font_size_body)
        let lineno = (col + 1).to_string().pad_end(4, ' ')
          |> pdf_bytes_of_string
        canvas.show_text_next_line(lineno + line)
      }
      canvas.next_line()
    }
    Blocks(blocks) =>
      // Handle blocks container by recursively rendering each block
      for sub_block in blocks {
        Block::render_to_canvas(sub_block, canvas)
      }
    List(items) =>
      for item in items {
        canvas.set_font(b"/F1", font_size_body)
        canvas.set_leading(0)
        canvas.move_text(10, 0)
        canvas.show_text("- ")
        Block::render_to_canvas(item, canvas)
        canvas.move_text(-10, 0)
      }
    MoonBitCodeBlock(code) => {
      canvas.set_font(b"/F4", font_size_body)
      for col, line in code {
        canvas.set_leading(font_size_body)
        let lineno = (col + 1).to_string().pad_end(4, ' ')
          |> pdf_bytes_of_string
        canvas.show_text(lineno)
        for cs in line {
          let (r, g, b) = color_style_to_rgb(cs.style)
          canvas.set_rgb_fill_color(r, g, b)
          canvas.show_text(cs.text)
        }
        canvas.next_line()
      }
      canvas.next_line()
    }
  }
}

///|

///|
/// Helper function to calculate block height considering indentation context
fn calculate_block_height(block : Block, indent_level : Int) -> Double {
  match block {
    Heading(level~, ..) => {
      let font_size = match level {
        1 => font_size_h1
        2 => font_size_h2
        3 => font_size_h3
        _ => font_size_body
      }
      font_size // Op_TL sets leading to font_size, Op_T_star consumes it
    }
    Paragraph(para) => {
      let para = para.map(x => match x {
        Plain(x) => x
        StrongEmphasis(x) => x
        Emphasis(x) => x
        StrongEmphasis_Emphasis(x) => x
        CodeSpan(x) => x
      })
      let ascii_count = para.fold(init=0, (acc, s) => acc + s.length())
      // Apply indentation context just like Block::write_to_canvas
      let max_cols = 80 - indent_level * 4
      let lines = (ascii_count + max_cols - 1) / max_cols // Ceiling division
      lines.to_double() * font_size_body
      // Op_TL sets leading to font_size_body, Op_T_star consumes it
    }
    CodeBlock(code~, ..) => code.length().to_double() * font_size_body
    BlankLine => font_size_body // Op_TL sets leading to font_size_body, Op_T_star consumes it
    Blocks(blocks) =>
      // Calculate height by summing heights of all contained blocks
      blocks.fold(init=0.0, fn(acc, sub_block) {
        acc + calculate_block_height(sub_block, indent_level)
      })
    List(items) => {
      let list_height = items.fold(init=0.0, fn(acc, item) {
        let item_height = match item {
          Paragraph(para) => {
            let para = para.map(x => match x {
              Plain(x) => x
              StrongEmphasis(x) => x
              Emphasis(x) => x
              StrongEmphasis_Emphasis(x) => x
              CodeSpan(x) => x
            })
            let ascii_count = para.fold(init=0, (acc, s) => acc + s.length())
            // Apply indentation and bullet context just like Block::write_to_canvas
            let max_cols = 80 - indent_level * 4 - 2 // Account for bullet and indentation
            let lines = (ascii_count + max_cols - 1) / max_cols
            lines.to_double() * font_size_body
          }
          _ =>
            // Handle other block types in lists using recursion with increased indent level
            calculate_block_height(item, indent_level + 1)
        }
        acc + item_height
      })
      list_height + font_size_body // Add extra line spacing for list
    }
    MoonBitCodeBlock(code) => code.length().to_double() * font_size_body
  }
}

///|
/// This function is intended to split a Doc into multiple PDF pages based on max_height.
fn Doc::split(
  self : Doc,
  max_height~ : Double,
  indent_level? : Int = 0,
) -> Array[Doc] {
  let result = []
  let mut current_height = 0.0
  let mut current_blocks = []
  for block in self.0 {
    // Calculate the height that this block would add using the helper function
    let block_height = calculate_block_height(block, indent_level)

    // Check if adding this block would exceed max_height
    if current_height + block_height > max_height && current_blocks.length() > 0 {
      // Split here: add current blocks to result and start new document
      result.push(Doc(current_blocks))
      current_blocks = []
      current_height = 0.0
    }

    // Add the block to current document
    current_blocks.push(block)
    current_height += block_height
  }

  // Add the final document if it has any blocks
  if current_blocks.length() > 0 {
    result.push(Doc(current_blocks))
  }

  // Ensure we always return at least one document, even if empty
  if result.length() == 0 {
    result.push(Doc([]))
  }
  result
}

///|
fn split_bytes(
  input : Bytes,
  init_cols~ : Int,
  max_cols~ : Int,
) -> Array[Bytes] {
  let mut cur_cols = init_cols
  let result = []
  let buffer = @buffer.new()
  for i in 0..<input.length() {
    let byte = input[i]

    // Check if adding this byte would exceed max_cols
    if cur_cols >= max_cols {
      // Flush current buffer to result and start new line
      result.push(buffer.to_bytes())
      buffer.reset()
      cur_cols = 0
    }
    buffer.write_byte(byte)
    cur_cols += 1
  }

  // Add remaining content in buffer if any
  if buffer.length() > 0 {
    result.push(buffer.to_bytes())
  }
  result
}
