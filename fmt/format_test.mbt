///|
test "Double" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(3.14, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="3.14")
  let offset = @fmt.Format::write(0.123456789, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="0.123456789")
}

///|
test "UInt" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(0xAABBCCEEU, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="2864434414")
  let offset = @fmt.Format::write(@fmt.LittleEndian(0xAABBCCEEU), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xee\xcc\xbb\xaa"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(0xAABBCCEEU), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xaa\xbb\xcc\xee"
    ),
  )
}

///|
test "Int" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(123456789, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="123456789")
  let offset = @fmt.Format::write(-123456789, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="-123456789")
  let offset = @fmt.Format::write(0xAABBCCEE, buffer, 0)
  inspect(memory_to_string(buffer, offset), content="-1430532882")
  let offset = @fmt.Format::write(@fmt.LittleEndian(0xAABBCCEE), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xee\xcc\xbb\xaa"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(0xAABBCCEE), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xaa\xbb\xcc\xee"
    ),
  )
}

///|
test "Iter" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write([1, 2, 3].iter(), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="[1,2,3]")
  let offset = @fmt.Format::write([1.23, 2.34, 3.45].iter(), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="[1.23,2.34,3.45]")
  let map : Map[Bytes, Double] = { "pi": 3.14, "e": 2.71 }
  let offset = @fmt.Format::write(map.iter(), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="[(pi,3.14),(e,2.71)]")
}

///|
test "Iter2" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let map : Map[Bytes, Double] = { "pi": 3.14, "e": 2.71 }
  let offset = @fmt.Format::write(map.iter2(), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="[(pi,3.14),(e,2.71)]")
}

///|
test "format_write" {
  let buffer = @fmt.Memory::make(1024, b'%')
  fn str(fmt : Bytes, data : Array[&@fmt.Format]) -> String raise {
    for i in 0..<buffer.length() {
      buffer[i] = b'%'
    }
    let offset = @fmt.format_write(fmt, data, buffer, 1)
    memory_to_string(buffer, offset + 2)
  }

  // Basic format string tests
  inspect(try! str(b"hello {} world", [123]), content="%hello 123 world%")
  inspect(try! str(b"{}{}", [1, 2]), content="%12%")
  inspect(try! str(b"={}={}=", [1, 2]), content="%=1=2=%")
  inspect(try! str(b"={}={}", [1, 2]), content="%=1=2%")
  inspect(try! str(b"{}={}", [1, 2]), content="%1=2%")

  // BigEndian format tests
  inspect(
    try! str(b"BE32: {}", [@fmt.BigEndian(0x12345678)]),
    content="%BE32: \u{12}4Vx%",
  )
  inspect(
    try! str(b"BE negative: {}", [@fmt.BigEndian(-1)]),
    content="%BE negative: ÿÿÿÿ%",
  )
  inspect(
    try! str(b"BE zero: {}", [@fmt.BigEndian(0)]),
    content="%BE zero: \u{0}\u{0}\u{0}\u{0}%",
  )
  inspect(
    try! str(b"BE uint: {}", [@fmt.BigEndian(0xAABBCCDDU)]),
    content="%BE uint: ª»ÌÝ%",
  )
  inspect(
    try! str(b"Mixed BE: {} and {}", [@fmt.BigEndian(0x1234), 999]),
    content="%Mixed BE: \u{0}\u{0}\u{12}4 and 999%",
  )

  // LittleEndian format tests  
  inspect(
    try! str(b"LE32: {}", [@fmt.LittleEndian(0x12345678)]),
    content="%LE32: xV4\u{12}%",
  )
  inspect(
    try! str(b"LE negative: {}", [@fmt.LittleEndian(-1)]),
    content="%LE negative: ÿÿÿÿ%",
  )
  inspect(
    try! str(b"LE zero: {}", [@fmt.LittleEndian(0)]),
    content="%LE zero: \u{0}\u{0}\u{0}\u{0}%",
  )
  inspect(
    try! str(b"LE uint: {}", [@fmt.LittleEndian(0xAABBCCDDU)]),
    content="%LE uint: ÝÌ»ª%",
  )
  inspect(
    try! str(b"Mixed LE: {} and {}", [@fmt.LittleEndian(0x5678), 777]),
    content="%Mixed LE: xV\u{0}\u{0} and 777%",
  )

  // HexUpper format tests
  inspect(
    try! str(b"HEX upper: {}", [@fmt.HexUpper(0x12345678)]),
    content="%HEX upper: 12345678%",
  )
  inspect(
    try! str(b"HEX upper negative: {}", [@fmt.HexUpper(-1)]),
    content="%HEX upper negative: FFFFFFFF%",
  )
  inspect(
    try! str(b"HEX upper zero: {}", [@fmt.HexUpper(0)]),
    content="%HEX upper zero: 0%",
  )
  inspect(
    try! str(b"HEX upper uint: {}", [@fmt.HexUpper(0xABCDEFU)]),
    content="%HEX upper uint: ABCDEF%",
  )
  inspect(
    try! str(b"HEX upper mixed: {} and {}", [@fmt.HexUpper(0xABC), 456]),
    content="%HEX upper mixed: ABC and 456%",
  )

  // HexLower format tests
  inspect(
    try! str(b"hex lower: {}", [@fmt.HexLower(0x12345678)]),
    content="%hex lower: 12345678%",
  )
  inspect(
    try! str(b"hex lower negative: {}", [@fmt.HexLower(-1)]),
    content="%hex lower negative: ffffffff%",
  )
  inspect(
    try! str(b"hex lower zero: {}", [@fmt.HexLower(0)]),
    content="%hex lower zero: 0%",
  )
  inspect(
    try! str(b"hex lower uint: {}", [@fmt.HexLower(0xABCDEFU)]),
    content="%hex lower uint: abcdef%",
  )
  inspect(
    try! str(b"hex lower mixed: {} and {}", [@fmt.HexLower(0xdef), 789]),
    content="%hex lower mixed: def and 789%",
  )

  // Complex mixed format tests with multiple format manipulators
  inspect(
    try! str(b"Complex: BE={}, LE={}, HEX={}, hex={}", [
      @fmt.BigEndian(0x1234),
      @fmt.LittleEndian(0x5678),
      @fmt.HexUpper(0xABCD),
      @fmt.HexLower(0xEF01),
    ]),
    content="%Complex: BE=\u{0}\u{0}\u{12}4, LE=xV\u{0}\u{0}, HEX=ABCD, hex=ef01%",
  )

  // Format with regular values and format manipulators
  inspect(
    try! str(b"Data: {}, BE: {}, normal: {}, HEX: {}", [
      42,
      @fmt.BigEndian(0x80818283),
      100,
      @fmt.HexUpper(0xFF),
    ]),
    content="%Data: 42, BE: , normal: 100, HEX: FF%",
  )

  // Multiple BigEndian and LittleEndian values
  inspect(
    try! str(b"BE1: {}, BE2: {}, LE1: {}, LE2: {}", [
      @fmt.BigEndian(0x1111),
      @fmt.BigEndian(0x2222),
      @fmt.LittleEndian(0x3333),
      @fmt.LittleEndian(0x4444),
    ]),
    content="%BE1: \u{0}\u{0}\u{11}\u{11}, BE2: \u{0}\u{0}\"\", LE1: 33\u{0}\u{0}, LE2: DD\u{0}\u{0}%",
  )

  // Edge cases with format manipulators
  inspect(
    try! str(b"Edge: {}", [@fmt.HexUpper(0xFFFFFFFFU)]),
    content="%Edge: FFFFFFFF%",
  )
  inspect(
    try! str(b"Edge: {}", [@fmt.HexLower(0xFFFFFFFFU)]),
    content="%Edge: ffffffff%",
  )
  inspect(
    try! str(b"Edge: {}", [@fmt.BigEndian(0xFFFFFFFFU)]),
    content="%Edge: ÿÿÿÿ%",
  )
  inspect(
    try! str(b"Edge: {}", [@fmt.LittleEndian(0xFFFFFFFFU)]),
    content="%Edge: ÿÿÿÿ%",
  )

  // Format strings with mixed content types
  inspect(
    try! str(b"Mixed types: int={}, hex={}, double={}, be={}", [
      123,
      @fmt.HexLower(0xabc),
      3.14,
      @fmt.BigEndian(0x1000),
    ]),
    content="%Mixed types: int=123, hex=abc, double=3.14, be=\u{0}\u{0}\u{10}\u{0}%",
  )
}

///|
test "format_write format dsl error" {
  let buffer = @fmt.Memory::make(1024, b'%')
  fn str(fmt : Bytes, data : Array[&@fmt.Format]) -> String raise {
    for i in 0..<buffer.length() {
      buffer[i] = b'%'
    }
    let offset = @fmt.format_write(fmt, data, buffer, 0)
    memory_to_string(buffer, offset)
  }

  inspect(
    try? str(b"hello {} world", []),
    content=(
      #|Err(DebugError("data.length() mismatch with placeholder's count"))
    ),
  )
  inspect(
    try? str(b"hello {} world", [1, 2]),
    content=(
      #|Err(DebugError("data.length() mismatch with placeholder's count"))
    ),
  )
}

///|
test "format_count" {
  // Test format strings without placeholders
  inspect(@fmt.format_count(b"hello world", []), content="11")
  inspect(@fmt.format_count(b"", []), content="0")

  // Test format strings with single placeholder
  inspect(@fmt.format_count(b"Hello {}", [42]), content="17") // "Hello " (6) + up to 11 digits for Int + "" (0)
  inspect(@fmt.format_count(b"Value: {}", [123]), content="18") // "Value: " (7) + up to 11 digits for Int + "" (0)

  // Test format strings with multiple placeholders
  inspect(@fmt.format_count(b"{} + {} = {}", [1, 2, 3]), content="39") // "" (0) + 11 + " + " (3) + 11 + " = " (3) + 11 + "" (0)
  inspect(@fmt.format_count(b"{}={}", [100, 200]), content="23") // "" (0) + 11 + "=" (1) + 11 + "" (0)

  // Test with different format types
  inspect(@fmt.format_count(b"Double: {}", [3.14]), content="33") // "Double: " (8) + 25 (max digits for Double) + "" (0)
  inspect(@fmt.format_count(b"Hex: {}", [@fmt.HexUpper(0xFF)]), content="13") // "Hex: " (5) + 8 (max hex digits for Int) + "" (0)
  inspect(@fmt.format_count(b"BE: {}", [@fmt.BigEndian(0x1234)]), content="8") // "BE: " (4) + 4 (bytes for BigEndian Int) + "" (0)

  // Test with bytes and byte views
  inspect(@fmt.format_count(b"Data: {}", [b"test"]), content="10") // "Data: " (6) + 4 (length of "test") + "" (0)

  // Test error cases - mismatched placeholder count
  inspect(
    try? @fmt.format_count(b"Hello {} world", []),
    content=(
      #|Err(DebugError("data.length() mismatch with placeholder's count"))
    ),
  )
  inspect(
    try? @fmt.format_count(b"Hello {} world", [1, 2]),
    content=(
      #|Err(DebugError("data.length() mismatch with placeholder's count"))
    ),
  )

  // Verify format_count provides upper bound for actual format_write
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let fmt = b"Test: {} and {}"
  let data : Array[&@fmt.Format] = [42, 3.14]
  let count_bound = try! @fmt.format_count(fmt, data)
  let actual_written = try! @fmt.format_write(fmt, data, buffer, 0)
  inspect(actual_written <= count_bound, content="true")
}

///|
test "BigEndian Int" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.BigEndian(0x12345678), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x124Vx"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(-1), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xff\xff\xff\xff"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(0), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x00\x00\x00\x00"
    ),
  )
}

///|
test "LittleEndian Int" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.LittleEndian(0x12345678), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"xV4\x12"
    ),
  )
  let offset = @fmt.Format::write(@fmt.LittleEndian(-1), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xff\xff\xff\xff"
    ),
  )
  let offset = @fmt.Format::write(@fmt.LittleEndian(0), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x00\x00\x00\x00"
    ),
  )
}

///|
test "BigEndian UInt" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.BigEndian(0x12345678U), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x124Vx"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(0xFFFFFFFFU), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xff\xff\xff\xff"
    ),
  )
  let offset = @fmt.Format::write(@fmt.BigEndian(0U), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x00\x00\x00\x00"
    ),
  )
}

///|
test "LittleEndian UInt" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.LittleEndian(0x12345678U), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"xV4\x12"
    ),
  )
  let offset = @fmt.Format::write(@fmt.LittleEndian(0xFFFFFFFFU), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\xff\xff\xff\xff"
    ),
  )
  let offset = @fmt.Format::write(@fmt.LittleEndian(0U), buffer, 0)
  inspect(
    bytes_view_of_memory(buffer, 0, offset),
    content=(
      #|b"\x00\x00\x00\x00"
    ),
  )
}

///|
test "HexUpper Int" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.HexUpper(0x12345678), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="12345678")
  let offset = @fmt.Format::write(@fmt.HexUpper(-1), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="FFFFFFFF")
  let offset = @fmt.Format::write(@fmt.HexUpper(0), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="0")
  let offset = @fmt.Format::write(@fmt.HexUpper(0xABCDEF), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="ABCDEF")
}

///|
test "HexLower Int" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.HexLower(0x12345678), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="12345678")
  let offset = @fmt.Format::write(@fmt.HexLower(-1), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="ffffffff")
  let offset = @fmt.Format::write(@fmt.HexLower(0), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="0")
  let offset = @fmt.Format::write(@fmt.HexLower(0xABCDEF), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="abcdef")
}

///|
test "HexUpper UInt" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.HexUpper(0x12345678U), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="12345678")
  let offset = @fmt.Format::write(@fmt.HexUpper(0xFFFFFFFFU), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="FFFFFFFF")
  let offset = @fmt.Format::write(@fmt.HexUpper(0U), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="0")
  let offset = @fmt.Format::write(@fmt.HexUpper(0xABCDEFU), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="ABCDEF")
}

///|
test "HexLower UInt" {
  let buffer = @fmt.Memory::make(1024, Byte::default())
  let offset = @fmt.Format::write(@fmt.HexLower(0x12345678U), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="12345678")
  let offset = @fmt.Format::write(@fmt.HexLower(0xFFFFFFFFU), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="ffffffff")
  let offset = @fmt.Format::write(@fmt.HexLower(0U), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="0")
  let offset = @fmt.Format::write(@fmt.HexLower(0xABCDEFU), buffer, 0)
  inspect(memory_to_string(buffer, offset), content="abcdef")
}
