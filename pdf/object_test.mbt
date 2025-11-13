///|
test "@fmt.Format for Object" {
  let buffer = @fmt.Memory::make(4096, Byte::default())
  let value = @pdf.Object::Integer(42)
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="42")
  let value = @pdf.Null
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="null")
  let value = @pdf.Boolean(true)
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="true")
  let value = @pdf.Boolean(false)
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="false")
  let value = @pdf.Real(3.14)
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="3.14")
  let value = @pdf.String(b"Hello, World!")
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="(Hello, World!)")
  let value = @pdf.Name(b"/Name")
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="/Name")
  let value = @pdf.Array([@pdf.Integer(1), @pdf.Integer(2), @pdf.Integer(3)])
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="[1 2 3]")
  let value = @pdf.Dictionary([
    ("/Type", @pdf.Name(b"/Example")),
    ("/Count", @pdf.Integer(3)),
  ])
  let offset = @fmt.write(value, buffer, 0)
  inspect(
    string_of_memory(buffer, offset),
    content=(
      #|<<
      #|  /Type /Example  
      #|  /Count 3
      #|>>
    ),
  )
  let value = @pdf.Object::Stream(
    @pdf.Dictionary([("/Length", @pdf.Integer(11))]),
    b"Hello World",
  )
  let offset = @fmt.write(value, buffer, 0)
  inspect(
    string_of_memory(buffer, offset),
    content=(
      #|<<
      #|  /Length 11
      #|>>
      #|stream
      #|Hello World
      #|endstream
    ),
  )
  let value = @pdf.Indirect(1)
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="1 0 R")
  let value = @pdf.Dictionary([
    ("/Type", @pdf.Name(b"/Pages")),
    ("/Kids", @pdf.Integer(1)),
    ("/Count", @pdf.Integer(1)),
  ])
  let offset = @fmt.write(value, buffer, 0)
  inspect(
    string_of_memory(buffer, offset),
    content=(
      #|<<
      #|  /Type /Pages  
      #|  /Kids 1  
      #|  /Count 1
      #|>>
    ),
  )
  let value = @pdf.Array([@pdf.Indirect(1)])
  let offset = @fmt.write(value, buffer, 0)
  inspect(string_of_memory(buffer, offset), content="[1 0 R]")
}

///|
test "write_ops" {
  let buffer = @fmt.Memory::make(4096, Byte::default())
  let mut offset = 0
  offset += @fmt.format_write(b" ET", [], buffer, offset)
  offset += @fmt.format_write(b" BT", [], buffer, offset)
  inspect(string_of_memory(buffer, offset), content=" ET BT")
}
