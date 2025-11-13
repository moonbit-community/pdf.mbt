# illusory0x0/fmt

A destination-passing style formatting library for MoonBit with extensible API design and efficient memory management.

## Quick Start

The core API revolves around the `@fmt.Format` trait, with helper functions `@fmt.format_count` and `@fmt.format_write`:

```mbt
///|
test "basic formatting" {
  let fmt = b"hello {}!"
  let data : Array[&@fmt.Format] = [b"moonbit"]
  let cnt = @fmt.format_count(fmt, data)
  let buf = @fmt.Memory::make(cnt, 0)
  let ofs = @fmt.format_write(fmt, data, buf, 0)
  inspect(string_of_memory(buf, ofs), content="hello moonbit!")
}
```

## Custom Formatters

Implement the `@fmt.Format` trait for your types:

```mbt
///|
struct Point {
  x : Int
  y : Int
}

///|
impl @fmt.Format for Point with count(self) {
  try! @fmt.format_count(b"({}, {})", [self.x, self.y])
}

///|
impl @fmt.Format for Point with write(self, buf, start) {
  try! @fmt.format_write(b"({}, {})", [self.x, self.y], buf, start)
}

///|
test "custom formatter" {
  let p = Point::{ x: 10, y: 20 }
  let cnt = @fmt.count(p)
  let buf = @fmt.Memory::make(cnt, 0)
  let ofs = @fmt.write(p, buf, 0)
  inspect(string_of_memory(buf, ofs), content="(10, 20)")
}
```

## Formatting Manipulators

### Number Formatting

```mbt
///|
test "hex formatting" {
  // Allocate a large buffer (1024 bytes) that can be reused for multiple operations
  // This avoids repeated memory allocation and is more efficient
  let buf = @fmt.Memory::make(1024, 0)
  let value = 255

  // Hex lowercase formatting
  let ofs1 = @fmt.write(@fmt.HexLower(value), buf, 0)
  inspect(string_of_memory(buf, ofs1), content="ff")

  // Hex uppercase formatting - reuse the same buffer
  let ofs2 = @fmt.write(@fmt.HexUpper(value), buf, 0)
  inspect(string_of_memory(buf, ofs2), content="FF")
}

///|
test "endianness formatting" {
  // Use a large reusable buffer (1024 bytes) for efficiency
  let buf = @fmt.Memory::make(1024, 0)
  let value : Int = 0x12345678

  // Big-endian: most significant byte first
  let be_ofs = @fmt.write(@fmt.BigEndian(value), buf, 0)
  inspect(
    bytes_of_memory_with_len(buf, be_ofs),
    content=(
      #|b"\x124Vx"
    ),
  )

  // Little-endian: least significant byte first - reuse buffer
  let le_ofs = @fmt.write(@fmt.LittleEndian(value), buf, 0)
  inspect(
    bytes_of_memory_with_len(buf, le_ofs),
    content=(
      #|b"xV4\x12"
    ),
  )
}
```

### Padding

```mbt
///|
test "padding examples" {
  // Use a large reusable buffer (1024 bytes) to avoid multiple allocations
  // More efficient than allocating separate buffers for each operation
  let buf = @fmt.Memory::make(1024, 0)
  let text = b"hello"

  // Left padding: text is right-aligned, padding on the left
  let left_ofs = @fmt.write(@fmt.Left(text, width=10, padding=' '), buf, 0)
  inspect(string_of_memory(buf, left_ofs), content="     hello")

  // Right padding: text is left-aligned, padding on the right - reuse buffer
  let right_ofs = @fmt.write(@fmt.Right(text, width=10, padding='*'), buf, 0)
  inspect(string_of_memory(buf, right_ofs), content="hello*****")

  // Center padding: text is centered - reuse buffer
  let center_ofs = @fmt.write(@fmt.Center(text, width=11, padding='-'), buf, 0)
  inspect(string_of_memory(buf, center_ofs), content="---hello---")
}
```

### Combining Manipulators

```mbt
///|
test "combined formatting" {
  // Use a large reusable buffer (1024 bytes) for efficiency
  let buf = @fmt.Memory::make(1024, 0)
  let number = 42

  // Hex + right padding: "2A" with zeros on the right
  let hex_padded = @fmt.Right(@fmt.HexUpper(number), width=8, padding='0')
  let ofs = @fmt.write(hex_padded, buf, 0)
  inspect(string_of_memory(buf, ofs), content="2A000000")
}
```

## Helper Functions

```mbt
///|
/// Convert memory buffer to string with C-style escape sequences
fn string_of_memory(mem : @fmt.Memory, len : Int) -> String {
  ascii_string_of_bytesview(bytes_of_memory_with_len(mem, len))
}

///|
/// Convert memory buffer to bytes
fn bytes_of_memory_with_len(mem : @fmt.Memory, len : Int) -> Bytes {
  Bytes::makei(len, i => mem[i])
}

///|
/// C-style string escaping for debugging/logging
pub fn ascii_string_of_bytesview(data : BytesView) -> String {
  let buffer = StringBuilder::new(size_hint=data.length() * 2)
  for b in data {
    match b {
      '\\' => buffer.write_string("\\\\")
      '\n' => buffer.write_string("\\n")
      '\r' => buffer.write_string("\\r")
      '\t' => buffer.write_string("\\t")
      '\b' => buffer.write_string("\\b")
      '\x0c' => buffer.write_string("\\f")
      c if c.to_int() < 32 || c.to_int() > 126 => {
        let code = c.to_int()
        buffer.write_string("\\")
        buffer.write_string((code / 64).to_string())
        buffer.write_string((code % 64 / 8).to_string())
        buffer.write_string((code % 8).to_string())
      }
      c => buffer.write_char(c.to_char())
    }
  }
  buffer.to_string()
}
```