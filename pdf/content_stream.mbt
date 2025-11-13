///|
pub fn ContentStream::iter(xs : ContentStream) -> Iter[GraphicOperator] {
  xs.0.iter()
}

///|
pub impl @fmt.Format for ContentStream with write(self, buf, start) {
  let xs = self.0
  let mut offset = start
  for x in xs {
    offset += @fmt.write(x, buf, offset)
  }
  offset - start
}

///|
pub impl @fmt.Format for ContentStream with count(xs) {
  xs.0.fold(init=0, (acc, x) => @fmt.count(x) + acc)
}

///|
pub fn ContentStream::to_stream(self : Self) -> Stream {
  let buffer = @fmt.Memory::make(@fmt.count(self), 0)
  let offset = @fmt.write(self, buffer, 0)
  let bytes = bytes_of_memory(buffer, offset)
  bytes
}

///|
pub fn ContentStream::to_stream_object(self : Self) -> Object {
  let stream = self.to_stream()
  let len = stream.0.length()
  Object::Stream(Dictionary([("/Length", Integer(len))]), stream)
}
