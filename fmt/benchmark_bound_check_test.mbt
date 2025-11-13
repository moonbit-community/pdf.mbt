///|
test (b : @bench.T) {
  let core_buffer = @buffer.new(size_hint=4096)
  let memory : @fmt.Memory = @fmt.Memory::make(4096, 0)
  let data : UInt = 1234567890
  // data.to_string().length() == 10 
  let write_uint_text_temp = FixedArray::make(10, b'\x00')
  b.bench(name="write_uint_text", fn() {
    for _ in 0..<400 {
      write_uint_text(data, core_buffer, write_uint_text_temp)
    }
    core_buffer.reset()
  })
  b.bench(name="write_uint_text_with_temp", fn() {
    for _ in 0..<400 {
      write_uint_text_with_temp(data, core_buffer)
    }
    core_buffer.reset()
  })
  b.bench(name="Format::write", fn() {
    let mut offset = 0
    for _ in 0..<400 {
      offset += @fmt.Format::write(data, memory, offset)
    }
  })
}

///|
test {
  let core_buffer = @buffer.new(size_hint=4096)
  let memory : @fmt.Memory = @fmt.Memory::make(4096, 0)
  let data : UInt = 1234567890
  // data.to_string().length() == 10 
  let write_uint_text_temp = FixedArray::make(10, b'\x00')
  write_uint_text(data, core_buffer, write_uint_text_temp)
  let offset = @fmt.Format::write(data, memory, 0)
  assert_eq(core_buffer.to_bytes()[:], bytes_view_of_memory(memory, 0, offset))
}

///|
fn write_uint_text(
  num : UInt,
  buffer : @buffer.Buffer,
  temp : FixedArray[Byte],
) -> Unit {
  for i = 9, value = num; i >= 0 && value > 0; i = i - 1, value = value / 10 {
    temp[i] = (value % 10 + '0'.to_uint()).to_byte()
  } else {
    buffer.write_bytesview(temp.unsafe_reinterpret_as_bytes()[i + 1:])
  }
}

///|
fn write_uint_text_with_temp(num : UInt, buffer : @buffer.Buffer) -> Unit {
  let temp = FixedArray::make(10, b'\x00')
  for i = 9, value = num; i >= 0 && value > 0; i = i - 1, value = value / 10 {
    temp[i] = (value % 10 + '0'.to_uint()).to_byte()
  } else {
    buffer.write_bytesview(temp.unsafe_reinterpret_as_bytes()[i + 1:])
  }
}

///|
fn ascii_bytes_to_string(bytes : Bytes) -> String {
  let buf = StringBuilder::new()
  for b in bytes {
    buf.write_char(b.to_char())
  }
  buf.to_string()
}

///|
test {
  let buf = @buffer.new(size_hint=100)
  let temp = FixedArray::make(10, b'\x00')
  write_uint_text(123456789, buf, temp)
  inspect(buf.to_bytes() |> ascii_bytes_to_string, content="123456789")
}
