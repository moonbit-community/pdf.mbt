/// provides utility functions for black-box testing

///|
fn memory_to_string(memory : @fmt.Memory, end : Int) -> String {
  let buf = StringBuilder::new()
  for i in 0..<end {
    buf.write_char(memory[i].to_char())
  }
  buf.to_string()
}

///|
fn bytes_of_memory(memory : @fmt.Memory) -> Bytes = "%identity"

///|
fn bytes_view_of_memory(
  memory : @fmt.Memory,
  start : Int,
  end : Int,
) -> BytesView {
  bytes_of_memory(memory)[start:end]
}

///|
fn fill_marker(memory : @fmt.Memory) -> Unit {
  for i in 0..<memory.length() {
    memory[i] = b'%'
  }
}
