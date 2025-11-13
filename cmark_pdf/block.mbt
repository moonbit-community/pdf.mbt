///|
fn coerce_seq_to_array(
  seq : @cmark.Seq[@cmark.Seq[String]],
) -> Array[Array[String]] {
  seq.to_array().map(@cmark.Seq::to_array)
}

///|
pub fn Block::from_cmark(block : @cmark.Block) -> Block {
  match block {
    Heading(node) => {
      let block_heading = node.v
      let level = block_heading.level
      let text = block_heading.inline.to_plain_text(break_on_soft=true)
        |> coerce_seq_to_array
      let text = text.flatten().join(" ")
      Heading(level~, text~)
    }
    Paragraph(node) => {
      let block_paragraph = node.v
      let para = Inline::from_cmark(block_paragraph.inline)
      Paragraph(para)
    }
    CodeBlock({ v: code_block, .. }) =>
      match code_block.info_string {
        Some({ v: "moonbit", .. }) => {
          let cs_lines = from_cmark_code_block(code_block)
          MoonBitCodeBlock(cs_lines)
        }
        Some({ v: text, .. }) => {
          let code = code_block.code
            .to_array()
            .map(x => x.v |> pdf_bytes_of_string)
          let language = text
          CodeBlock(language~, code~)
        }
        None => {
          let code = code_block.code
            .to_array()
            .map(x => x.v |> pdf_bytes_of_string)
          CodeBlock(language="", code~)
        }
      }
    BlankLine(_) => BlankLine
    // Handle all other block types by converting them to Paragraph with Plain inline text
    BlockQuote(node) => {
      // Extract text content from the quoted block and convert to paragraph
      let quoted_texts = extract_texts_from_block(node.v.block)
      let plain_elements = quoted_texts.map(fn(text) { Plain(text) })
      Paragraph(plain_elements)
    }
    Blocks(node) => {
      // For multiple blocks, convert the first one or return empty paragraph
      let blocks = node.v.to_array()
      match blocks {
        [] => Paragraph([Plain("")])
        [first, ..] => Block::from_cmark(first)
      }
    }
    HtmlBlock(node) => {
      // Convert HTML block to plain text paragraph
      let html_block = node.v
      let html_lines = html_block.0.to_array().map(x => x.v)
      let plain_elements = html_lines.map(fn(line) { Plain(line) })
      Paragraph(plain_elements)
    }
    LinkRefDefinition(node) => {
      // Convert link definition to plain text paragraph
      let link_def = node.v
      let text = match link_def.label {
        Some(label) => "[\{label.key}]"
        None => "[undefined]"
      }
      Paragraph([Plain(text)])
    }
    List(node) => {
      // Convert each list item to a Block and collect into List(Array[Block])
      let list = node.v
      let items = list.items.to_array()
      let list_items = items.map(fn(item) {
        let block = item.v.block
        Block::from_list_block(block)
      })
      List(list_items)
    }
    ThematicBreak(_) =>
      // Convert thematic break to plain text representation
      Paragraph([Plain("---")])
    ExtMathBlock({ v: code_block, .. }) => {
      // Handle math blocks similar to code blocks but as plain text
      let math_lines = code_block.code.to_array().map(x => x.v)
      let plain_elements = math_lines.map(fn(line) { Plain(line) })
      Paragraph(plain_elements)
    }
    ExtTable(node) => {
      // Convert table to plain text paragraph
      let table = node.v
      let rows = table.rows.to_array()
      let row_texts = rows.map(fn(row_pair) {
        let row = row_pair.0.v
        match row {
          Header(cells) | Data(cells) => {
            let cell_texts = cells
              .to_array()
              .map(fn(cell) {
                let text = cell.0.to_plain_text(break_on_soft=true)
                  |> coerce_seq_to_array
                let text = text.flatten().join(" ")
                text
              })
            cell_texts.join(" | ")
          }
          Sep(_) => "---"
        }
      })
      let plain_elements = row_texts.map(fn(row_text) { Plain(row_text) })
      Paragraph(plain_elements)
    }
    ExtFootnoteDefinition(node) => {
      // Convert footnote to plain text paragraph
      let footnote = node.v
      let footnote_texts = extract_texts_from_block(footnote.block)
      let footnote_label = "[\{footnote.label.key}]:"
      let plain_elements = [Plain(footnote_label)] +
        footnote_texts.map(fn(text) { Plain(text) })
      Paragraph(plain_elements)
    }
  }
}

///|
/// Helper function to extract text content from a block recursively.
/// Returns an array of individual text pieces without joining them.
fn extract_texts_from_block(block : @cmark.Block) -> Array[String] {
  match block {
    Heading(node) => {
      let texts = node.v.inline.to_plain_text(break_on_soft=true)
        |> coerce_seq_to_array
      texts.flatten()
    }
    Paragraph(node) => {
      let texts = node.v.inline.to_plain_text(break_on_soft=true)
        |> coerce_seq_to_array
      texts.flatten()
    }
    CodeBlock({ v: code_block, .. }) => code_block.code.to_array().map(x => x.v)
    BlankLine(_) => []
    BlockQuote(node) => extract_texts_from_block(node.v.block)
    Blocks(node) => {
      let blocks = node.v.to_array()
      blocks.map(extract_texts_from_block).flatten()
    }
    HtmlBlock(node) => {
      let html_block = node.v
      html_block.0.to_array().map(x => x.v)
    }
    LinkRefDefinition(node) =>
      match node.v.label {
        Some(label) => ["[\{label.key}]"]
        None => ["[undefined]"]
      }
    List(node) => {
      let items = node.v.items.to_array()
      items
      .map(fn(item) {
        let texts = extract_texts_from_block(item.v.block)
        texts.map(fn(text) { " \{text}" })
      })
      .flatten()
    }
    ThematicBreak(_) => ["---"]
    ExtMathBlock({ v: code_block, .. }) =>
      code_block.code.to_array().map(x => x.v)
    ExtTable(node) => {
      let table = node.v
      let rows = table.rows.to_array()
      rows
      .map(fn(row_pair) {
        let row = row_pair.0.v
        match row {
          Header(cells) | Data(cells) =>
            cells
            .to_array()
            .map(fn(cell) {
              let texts = cell.0.to_plain_text(break_on_soft=true)
                |> coerce_seq_to_array
              texts.flatten()
            })
            .flatten()
          Sep(_) => ["---"]
        }
      })
      .flatten()
    }
    ExtFootnoteDefinition(node) => {
      let footnote = node.v
      let footnote_texts = extract_texts_from_block(footnote.block)
      ["[\{footnote.label.key}]:"] + footnote_texts
    }
  }
}

///|
/// Helper function to convert a @cmark.Block to Block for list items
fn Block::from_list_block(block : @cmark.Block) -> Block {
  match block {
    Paragraph(node) => {
      let block_paragraph = node.v
      let para = Inline::from_cmark(block_paragraph.inline)
      Paragraph(para)
    }
    BlankLine(_) => BlankLine
    Blocks(node) => {
      // Handle nested blocks - convert each block to a Block element
      let blocks = node.v.to_array()
      let list_items = blocks.map(Block::from_list_block)
      Blocks(list_items)
    }
    List(node) => {
      // Handle nested lists - convert each list item
      let list = node.v
      let items = list.items.to_array()
      let list_items = items.map(fn(item) {
        let block = item.v.block
        Block::from_list_block(block)
      })
      List(list_items)
    }
    // For other block types, convert them to paragraphs with plain text
    Heading(node) => {
      let block_heading = node.v
      let text = block_heading.inline.to_plain_text(break_on_soft=true)
        |> coerce_seq_to_array
      let flattened_text = text.flatten().join(" ")
      Paragraph([Plain(flattened_text)])
    }
    CodeBlock({ v: code_block, .. }) => {
      let code_lines = code_block.code.to_array().map(x => x.v)
      let code_text = code_lines.join("\n")
      Paragraph([Plain(code_text)])
    }
    BlockQuote(node) =>
      // Convert quoted block to list element
      Block::from_list_block(node.v.block)
    HtmlBlock(node) => {
      // Convert HTML block to plain text paragraph
      let html_block = node.v
      let html_lines = html_block.0.to_array().map(x => x.v)
      let html_text = html_lines.join("\n")
      Paragraph([Plain(html_text)])
    }
    LinkRefDefinition(node) => {
      // Convert link definition to plain text paragraph
      let link_def = node.v
      let text = match link_def.label {
        Some(label) => "[\{label.key}]"
        None => "[undefined]"
      }
      Paragraph([Plain(text)])
    }
    ThematicBreak(_) =>
      // Convert thematic break to plain text representation
      Paragraph([Plain("---")])
    ExtMathBlock({ v: code_block, .. }) => {
      // Handle math blocks as plain text
      let math_lines = code_block.code.to_array().map(x => x.v)
      let math_text = math_lines.join("\n")
      Paragraph([Plain(math_text)])
    }
    ExtTable(node) => {
      // Convert table to plain text paragraph
      let table = node.v
      let rows = table.rows.to_array()
      let row_texts = rows.map(fn(row_pair) {
        let row = row_pair.0.v
        match row {
          Header(cells) | Data(cells) => {
            let cell_texts = cells
              .to_array()
              .map(fn(cell) {
                let text = cell.0.to_plain_text(break_on_soft=true)
                  |> coerce_seq_to_array
                text.flatten().join(" ")
              })
            cell_texts.join(" | ")
          }
          Sep(_) => "---"
        }
      })
      let table_text = row_texts.join("\n")
      Paragraph([Plain(table_text)])
    }
    ExtFootnoteDefinition(node) => {
      // Convert footnote to plain text paragraph
      let footnote = node.v
      let footnote_texts = extract_texts_from_block(footnote.block)
      let footnote_text = "[\{footnote.label.key}]: " + footnote_texts.join(" ")
      Paragraph([Plain(footnote_text)])
    }
  }
}

///|
test "Block::from_list_item with simple paragraph" {
  let md_str = "- Simple item"
  let doc = @cmark.Doc::from_string(md_str)
  let block = doc.block
  let block = Block::from_cmark(block)
  @json.inspect(block, content=[
    "List",
    [["Paragraph", [["Plain", "Simple item"]]]],
  ])
}
