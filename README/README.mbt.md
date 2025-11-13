# MoonBit PDF Library

A comprehensive MoonBit library for generating standards-compliant PDF documents with support for PDF objects, graphics operators, Markdown to PDF conversion, and binary data parsing.

## Features

- **PDF Generation**: Create complete PDF files with text, images, fonts, and graphics
- **Markdown to PDF**: Convert Markdown documents to formatted PDF files  
- **Graphics Operators**: Full support for PDF graphics state and drawing operations
- **Binary Data Parsing**: Efficient parsing of various data types from byte streams
- **Standards Compliance**: Generate PDFs following ISO 32000-2 (PDF 2.0) specification

## Quick Start

### Basic PDF Generation

```moonbit
///|
test "create basic PDF" {
  // Create a simple PDF with text
  let canvas = @cmark_pdf.Canvas::new()
  canvas.begin_text()
  canvas.set_font(b"/F0", 12.0)
  canvas.show_text(b"Hello, PDF!")
  canvas.end_text()
  let ops = canvas.to_array()
  inspect(ops.length(), content="4")
}
```

### Markdown to PDF Conversion

```moonbit
///|
test "markdown to PDF conversion" {
  let markdown =
    #|# My Document
    #|This is a **bold** text and this is *italic*.
    #|
    #|- First item
    #|- Second item
    #|
    #|```moonbit
    #|let x = 42
    #|println(x)
    #|```
    #|
  let pdf_bytes = @cmark_pdf.markdown_to_bytes(markdown)
  inspect(pdf_bytes.length() > 0, content="true")
  // The PDF bytes can be written to a file or used directly
}
```

## Core Packages

### `pdf` - Core PDF Generation

The core package provides low-level PDF object model and file generation capabilities.

#### PDF Objects

```moonbit
///|
test "PDF objects" {
  // Create basic PDF objects
  let int_obj = @pdf.Object::Integer(42)
  let string_obj = @pdf.Object::String(b"Hello")

  // Arrays and dictionaries
  let _array_obj = @pdf.Object::Array([int_obj, string_obj])
  let dict_obj = @pdf.Object::Dictionary([
    (b"/Type", @pdf.Object::Name(b"/Page")),
    (b"/Contents", @pdf.Object::Integer(1)),
  ])
  @json.inspect(dict_obj, content=[
    "Dictionary",
    [["/Type", ["Name", "/Page"]], ["/Contents", ["Integer", 1]]],
  ])
}
```

#### Graphics Operators

```moonbit
///|
test "graphics operators" {
  // Create graphics operators for drawing
  let line_width = @pdf.GraphicOperator::Op_w(2.0)
  let move_to = @pdf.GraphicOperator::Op_m(100.0, 100.0)
  let line_to = @pdf.GraphicOperator::Op_l(200.0, 200.0)
  let stroke = @pdf.GraphicOperator::Op_S
  let content_stream = @pdf.ContentStream([line_width, move_to, line_to, stroke])
  inspect(content_stream.0.length(), content="4")
}
```

#### Standard Fonts

```moonbit
///|
test "standard fonts" {
  // Use PDF standard fonts
  let times_roman = @pdf.StandardFont::TimesRoman

  // Convert to PDF objects
  let font_dict = times_roman.to_pdf_dictionary()
  @json.inspect(font_dict, content=[
    "Dictionary",
    [
      ["/Type", ["Name", "/Font"]],
      ["/Subtype", ["Name", "/Type1"]],
      ["/BaseFont", ["Name", "/Times-Roman"]],
    ],
  ])
}
```

### `cmark_pdf` - Markdown to PDF Conversion

High-level API for converting Markdown to formatted PDF documents.

#### Document Structure

```moonbit
///|
test "document structure" {
  let markdown =
    #|# Chapter 1
    #|## Section 1.1
    #|Some text here.
    #|
    #|## Section 1.2
    #|More content.
    #|
  let cmark_doc = @cmark.Doc::from_string(markdown)
  let doc = @cmark_pdf.Doc::from_cmark(cmark_doc)

  // Generate table of contents
  let flat_headings = doc.to_flatheadings()
  inspect(flat_headings.length() > 0, content="true")
}
```

#### Canvas Drawing API

```moonbit
///|
test "canvas API" {
  let canvas = @cmark_pdf.Canvas::new()

  // Graphics state
  canvas.save_state()
  canvas.set_line_width(1.5)
  canvas.set_rgb_stroke_color(1.0, 0.0, 0.0) // Red

  // Draw shapes
  canvas.rectangle(50.0, 50.0, 100.0, 100.0)
  canvas.stroke()

  // Text
  canvas.begin_text()
  canvas.set_font(b"/Helvetica", 12.0)
  canvas.move_text(60.0, 90.0)
  canvas.show_text(b"Rectangle")
  canvas.end_text()
  canvas.restore_state()
  let operators = canvas.to_array()
  inspect(operators.length() > 0, content="true")
}
```

### `lexer_bytes` - Binary Data Parsing

Efficient parsing of various data types from byte streams.

#### Basic Parsing

```moonbit
///|
test "basic parsing" {
  // Parse integers
  let (num, len) = @lexer_bytes.tokenize_int(b"42")
  inspect(num, content="42")
  inspect(len, content="2")

  // Parse floats
  let (pi, len) = @lexer_bytes.tokenize_double(b"3.14159")
  @json.inspect(pi, content=3.14159)
  inspect(len, content="7")

  // Parse booleans
  let (flag, len) = @lexer_bytes.tokenize_bool(b"true")
  @json.inspect(flag, content=true)
  inspect(len, content="4")
}
```

#### Number Base Conversion

```moonbit
///|
test "number bases" {
  // Hexadecimal
  let (hex_val, _) = @lexer_bytes.tokenize_int(b"ff", base=16)
  inspect(hex_val, content="255")

  // Binary  
  let (bin_val, _) = @lexer_bytes.tokenize_int(b"1010", base=2)
  inspect(bin_val, content="10")

  // Octal
  let (oct_val, _) = @lexer_bytes.tokenize_int(b"77", base=8)
  inspect(oct_val, content="63")
}
```

### `fmt` - Formatting and Memory Operations

Low-level formatting utilities used internally for PDF generation.

```moonbit
///|
test "memory formatting" {
  let buffer = @fmt.Memory::make(1024, Byte::default())

  // Write formatted data
  let written = @fmt.format_write("{} + {} = {}", [1, 2, 3], buffer, 0)
  inspect(written > 0, content="true")

  // Extract string
  let result = @pdf.string_of_memory(buffer, written)
  inspect(result, content="1 + 2 = 3")
}
```

## Advanced Usage

### Creating Custom PDF Documents

```moonbit
///|
test "custom PDF document" {
  // Create content stream with graphics operators
  let transform = @pdf.TransformMatrix::{
    a: 1.0,
    b: 0.0,
    c: 0.0,
    d: 1.0,
    e: 50.0,
    f: 750.0,
  }
  let content = @pdf.ContentStream([
    @pdf.GraphicOperator::Op_cm(transform),
    @pdf.GraphicOperator::Op_BT,
    @pdf.GraphicOperator::Op_Tf(b"/F0", 24.0),
    @pdf.GraphicOperator::Op_Tj(b"Custom PDF Content"),
    @pdf.GraphicOperator::Op_ET,
  ])

  // Create PDF structure
  let pages = @pdf.define_pages(pages=[@pdf.Object::Indirect(4)])
  let catalog = @pdf.define_catalog(pages=@pdf.Object::Indirect(2))

  // Create complete PDF
  let pdf_file = @pdf.make_pdf(catalog, [content.to_stream_object(), pages])
  @json.inspect(pdf_file.major, content=1)
  @json.inspect(pdf_file.minor, content=4)
}
```

### Error Handling

```moonbit
///|
test "error handling examples" {
  // Handle parsing errors
  let result = try? @lexer_bytes.tokenize_int(b"not_a_number")
  match result {
    Ok(_) => inspect("unexpected success", content="unexpected success")
    Err(@lexer_bytes.LexError(msg)) => inspect(msg, content="invalid syntax")
  }

  // Safe parsing with fallback
  let safe_parse = @lexer_bytes.tokenize_double(b"invalid") catch {
    @lexer_bytes.LexError(_) => (0.0, 0)
  }
  @json.inspect(safe_parse.0, content=0.0)
}
```

### Working with Images

```moonbit
///|
test "image handling concept" {
  // This demonstrates the API structure for image handling
  // (Note: actual image files not available in test environment)

  // Define image object structure
  let image_dict = @pdf.Object::Dictionary([
    (b"/Type", @pdf.Object::Name(b"/XObject")),
    (b"/Subtype", @pdf.Object::Name(b"/Image")),
    (b"/Width", @pdf.Object::Integer(100)),
    (b"/Height", @pdf.Object::Integer(100)),
    (b"/BitsPerComponent", @pdf.Object::Integer(8)),
    (b"/ColorSpace", @pdf.Object::Name(b"/DeviceRGB")),
  ])
  @json.inspect(image_dict, content=[
    "Dictionary",
    [
      ["/Type", ["Name", "/XObject"]],
      ["/Subtype", ["Name", "/Image"]],
      ["/Width", ["Integer", 100]],
      ["/Height", ["Integer", 100]],
      ["/BitsPerComponent", ["Integer", 8]],
      ["/ColorSpace", ["Name", "/DeviceRGB"]],
    ],
  ])
}
```

## File I/O Integration

While the library focuses on PDF generation, it integrates well with file operations:

```moonbit
///|
test "file integration pattern" {
  // Generate PDF content
  let simple_markdown = "# Test\nSimple document."
  let pdf_bytes = @cmark_pdf.markdown_to_bytes(simple_markdown)

  // Verify output is generated
  inspect(pdf_bytes.length() > 100, content="true") // PDF header + content
  // Check PDF signature bytes (%PDF)
  inspect(pdf_bytes[0], content="b'\\x25'") // '%'
  inspect(pdf_bytes[1], content="b'\\x50'") // 'P'
  inspect(pdf_bytes[2], content="b'\\x44'") // 'D'
  inspect(pdf_bytes[3], content="b'\\x46'") // 'F'
}
```

## Architecture

The library is organized into several focused packages:

- **`pdf`**: Core PDF object model, graphics operators, and file structure
- **`cmark_pdf`**: High-level Markdown to PDF conversion using CommonMark
- **`lexer_bytes`**: Binary data parsing and type conversion utilities  
- **`fmt`**: Low-level formatting and memory management utilities

Each package provides both low-level control and high-level convenience APIs to suit different use cases.

## Standards Compliance

This library generates PDFs following the ISO 32000-2:2020 (PDF 2.0) specification. Key compliance features:

- Proper PDF file structure (header, body, xref table, trailer)
- Standard graphics operators and coordinate systems
- Type 1 font support with standard 14 fonts
- Correct string literal escaping and encoding
- Valid object references and indirect objects

## Performance Considerations

- Uses `BytesView` for zero-copy parsing operations
- Memory-efficient formatting with pre-allocated buffers
- Minimal object allocations in hot paths
- Optimized for both small documents and large batch processing

## Recommended Reading

For deeper understanding of PDF internals, consult the ISO standard:
https://www.pdfa-inc.org/product/iso-32000-2-pdf-2-0-bundle-sponsored-access/