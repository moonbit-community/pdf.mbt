///|
pub impl Format for UInt16 with write(value, buffer, start) {
  let value32 = value.to_uint()
  Format::write(value32, buffer, start)
}

///|
/// supremum
pub impl Format for UInt16 with count(_) -> Int {
  UInt16_Digits10
}

///|
pub impl LittleEndianFormat for UInt16 with write(value, buffer, start) {
  let b0 = (value.to_uint() & 0xFF).to_byte()
  let b1 = ((value.to_uint() >> 8) & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  2
}

///|
/// supremum
pub impl LittleEndianFormat for UInt16 with count(_) -> Int {
  2
}

///|
pub impl BigEndianFormat for UInt16 with write(value, buffer, start) {
  let b0 = ((value.to_uint() >> 8) & 0xFF).to_byte()
  let b1 = (value.to_uint() & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  2
}

///|
/// supremum
pub impl BigEndianFormat for UInt16 with count(_) -> Int {
  2
}

///|
pub impl HexLowerFormat for UInt16 with write(value, buffer, start) {
  let value_uint = value.to_uint() & 0xFFFF
  HexLowerFormat::write(value_uint, buffer, start)
}

///|
/// supremum
pub impl HexLowerFormat for UInt16 with count(_) -> Int {
  4
}

///|
pub impl HexUpperFormat for UInt16 with write(value, buffer, start) {
  let value_uint = value.to_uint() & 0xFFFF
  HexUpperFormat::write(value_uint, buffer, start)
}

///|
/// supremum
pub impl HexUpperFormat for UInt16 with count(_) -> Int {
  4
}

///|
fn reverse(xs : Memory, start : Int, end : Int) -> Unit {
  let mut i = start
  let mut j = end - 1
  while i < j {
    let temp = xs[i]
    xs[i] = xs[j]
    xs[j] = temp
    i += 1
    j -= 1
  }
}

///|
pub impl Format for UInt with write(value, buffer, start) {
  if value == 0 {
    buffer[start + 0] = '0'
    return 1
  }
  let mut value = value
  let mut offset = start
  while value > 0 {
    let rem = value % 10
    buffer[offset] = UInt::to_byte(rem + b'0'.to_uint())
    value /= 10
    offset += 1
  }
  reverse(buffer, start, offset)
  offset - start
}

///|
/// supremum
pub impl Format for UInt with count(_) -> Int {
  UInt_Digits10
}

///|
pub impl LittleEndianFormat for UInt with write(value, buffer, start) {
  let b0 = (value & 0xFF).to_byte()
  let b1 = ((value >> 8) & 0xFF).to_byte()
  let b2 = ((value >> 16) & 0xFF).to_byte()
  let b3 = ((value >> 24) & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  buffer[start + 2] = b2
  buffer[start + 3] = b3
  4
}

///|
/// supremum
pub impl LittleEndianFormat for UInt with count(_) -> Int {
  4
}

///|
pub impl BigEndianFormat for UInt with write(value, buffer, start) {
  let b0 = ((value >> 24) & 0xFF).to_byte()
  let b1 = ((value >> 16) & 0xFF).to_byte()
  let b2 = ((value >> 8) & 0xFF).to_byte()
  let b3 = (value & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  buffer[start + 2] = b2
  buffer[start + 3] = b3
  4
}

///|
/// supremum
pub impl BigEndianFormat for UInt with count(_) -> Int {
  4
}

///|
pub impl HexLowerFormat for UInt with write(value, buffer, start) {
  if value == 0 {
    buffer[start + 0] = '0'
    return 1
  }
  let mut value = value
  let mut offset = start
  while value > 0 {
    let rem = value & 0xF
    buffer[offset] = lower_digit_table[rem.reinterpret_as_int()]
    value = value >> 4
    offset += 1
  }
  reverse(buffer, start, offset)
  offset - start
}

///|
/// supremum
pub impl HexLowerFormat for UInt with count(_) -> Int {
  8
}

///|
pub impl HexUpperFormat for UInt with write(value, buffer, start) {
  if value == 0 {
    buffer[start + 0] = '0'
    return 1
  }
  let mut value = value
  let mut offset = start
  while value > 0 {
    let rem = value & 0xF
    buffer[offset] = upper_digit_table[rem.reinterpret_as_int()]
    value = value >> 4
    offset += 1
  }
  reverse(buffer, start, offset)
  offset - start
}

///|
/// supremum
pub impl HexUpperFormat for UInt with count(_) -> Int {
  8
}

///|
pub impl Format for Int16 with write(value, buffer, start) {
  let value32 = value.to_int()
  Format::write(value32, buffer, start)
}

///|
/// supremum
pub impl Format for Int16 with count(_) -> Int {
  Int16_Digits10
}

///|
pub impl LittleEndianFormat for Int16 with write(value, buffer, start) {
  let b0 = (value.to_int() & 0xFF).to_byte()
  let b1 = ((value.to_int() >> 8) & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  2
}

///|
/// supremum
pub impl LittleEndianFormat for Int16 with count(_) -> Int {
  2
}

///|
pub impl BigEndianFormat for Int16 with write(value, buffer, start) {
  let b0 = ((value.to_int() >> 8) & 0xFF).to_byte()
  let b1 = (value.to_int() & 0xFF).to_byte()
  buffer[start + 0] = b0
  buffer[start + 1] = b1
  2
}

///|
/// supremum
pub impl BigEndianFormat for Int16 with count(_) -> Int {
  2
}

///|
pub impl HexLowerFormat for Int16 with write(value, buffer, start) {
  let value_uint = value.to_int().reinterpret_as_uint() & 0xFFFF
  HexLowerFormat::write(value_uint, buffer, start)
}

///|
/// supremum
pub impl HexLowerFormat for Int16 with count(_) -> Int {
  4
}

///|
pub impl HexUpperFormat for Int16 with write(value, buffer, start) {
  let value_uint = value.to_int().reinterpret_as_uint() & 0xFFFF
  HexUpperFormat::write(value_uint, buffer, start)
}

///|
/// supremum
pub impl HexUpperFormat for Int16 with count(_) -> Int {
  4
}

///|
pub impl Format for Int with write(value, buffer, start) {
  if value >= 0 {
    let value = value.reinterpret_as_uint()
    Format::write(value, buffer, start)
  } else {
    let value = (-value).reinterpret_as_uint()
    buffer[start] = '-'
    Format::write(value, buffer, start + 1) + 1
  }
}

///|
/// supremum
pub impl Format for Int with count(_) -> Int {
  Int_Digits10
}

///|
pub impl LittleEndianFormat for Int with write(value, buffer, start) {
  LittleEndianFormat::write(value.reinterpret_as_uint(), buffer, start)
}

///|
/// supremum
pub impl LittleEndianFormat for Int with count(_) -> Int {
  4
}

///|
pub impl BigEndianFormat for Int with write(value, buffer, start) {
  BigEndianFormat::write(value.reinterpret_as_uint(), buffer, start)
}

///|
/// supremum
pub impl BigEndianFormat for Int with count(_) -> Int {
  4
}

///|
pub impl HexLowerFormat for Int with write(value, buffer, start) {
  HexLowerFormat::write(value.reinterpret_as_uint(), buffer, start)
}

///|
/// supremum
pub impl HexLowerFormat for Int with count(_) -> Int {
  8
}

///|
pub impl HexUpperFormat for Int with write(value, buffer, start) {
  HexUpperFormat::write(value.reinterpret_as_uint(), buffer, start)
}

///|
/// supremum
pub impl HexUpperFormat for Int with count(_) -> Int {
  8
}

///|
pub impl Format for Double with write(value, buffer, start) {
  let repr = ryu_to_repr(value)
  match repr {
    Nan => memcpy(buffer, start, b"NaN")
    Negative(Zero) => memcpy(buffer, start, b"0")
    Negative(Infinity) => memcpy(buffer, start, b"-Infinity")
    Negative(Normal(v)) =>
      write_floating_decimal64_to_memory(buffer, start, v, true)
    Positive(Zero) => memcpy(buffer, start, b"0")
    Positive(Infinity) => memcpy(buffer, start, b"Infinity")
    Positive(Normal(v)) =>
      write_floating_decimal64_to_memory(buffer, start, v, false)
  }
}

///|
/// upper bound
pub impl Format for Double with count(_) -> Int {
  /// https://en.cppreference.com/w/cpp/types/numeric_limits/max_digits10.html
  25
}

///|
pub impl Format for Bytes with write(value, buffer, start) {
  for i in 0..<value.length() {
    buffer[start + i] = value[i]
  }
  value.length()
}

///|
/// supremum
pub impl Format for Bytes with count(self) -> Int {
  self.length()
}

///|
pub impl Format for BytesView with write(value, buffer, start) {
  for i in 0..<value.length() {
    buffer[start + i] = value[i]
  }
  value.length()
}

///|
/// supremum
pub impl Format for BytesView with count(self) -> Int {
  self.length()
}

///|
pub impl Format for Byte with write(value, buffer, start) {
  buffer[start] = value
  1
}

///|
/// supremum
pub impl Format for Byte with count(_) -> Int {
  1
}

///|
pub impl[A : Format] Format for Iter[A] with write(value, buffer, start) {
  let mut offset = start
  offset += Format::write(b'[', buffer, offset)
  for x in value {
    offset += Format::write(x, buffer, offset)
    offset += Format::write(b',', buffer, offset)
  }
  // overwrite last ',' with ']'
  buffer[offset - 1] = b']'
  offset - start
}

///|
/// supremum
pub impl[A : Format] Format for Iter[A] with count(self) -> Int {
  // init = 1 for '['
  // +1 for each ','
  // overwrite last ',' with ']'
  self.fold(init=1, (acc, x) => acc + x.count() + 1)
}

///|
pub impl[A : Format, B : Format] Format for Iter2[A, B] with write(
  value,
  buffer,
  start,
) {
  let mut offset = start
  offset += Format::write(b'[', buffer, offset)
  for x, y in value {
    offset += Format::write(b'(', buffer, offset)
    offset += Format::write(x, buffer, offset)
    offset += Format::write(b',', buffer, offset)
    offset += Format::write(y, buffer, offset)
    offset += Format::write(b')', buffer, offset)
    // delimiter for pairs
    offset += Format::write(b',', buffer, offset)
  }
  // overwrite last ',' with ']'
  buffer[offset - 1] = b']'
  offset - start
}

///|
/// supremum
pub impl[A : Format, B : Format] Format for Iter2[A, B] with count(self) -> Int {
  let mut supremum = 1 // for '['
  for x, y in self {
    // 4 for '(', ',', ')', ','
    supremum += 4 + x.count() + y.count()
  }
  // overwrite last ',' with ']'
  supremum
}

///|
pub impl[A : Format, B : Format] Format for (A, B) with write(
  value,
  buffer,
  start,
) {
  let mut offset = start
  offset += Format::write(b'(', buffer, offset)
  offset += Format::write(value.0, buffer, offset)
  offset += Format::write(b',', buffer, offset)
  offset += Format::write(value.1, buffer, offset)
  offset += Format::write(b')', buffer, offset)
  offset - start
}

///|
pub impl[A : Format, B : Format] Format for (A, B) with count(self) -> Int {
  // 3 for '(', ',', ')'
  3 + self.0.count() + self.1.count()
}
