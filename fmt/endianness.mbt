///|
pub(all) struct BigEndian[T](T)

///|
/// if contract is violated, behavior is undefined
pub(open) trait BigEndianFormat {
  /// Write the `value` into `buffer` as the `start` position,
  /// and return the number of bytes written.
  ///
  /// The number of bytes written must not exceed count().
  write(value : Self, buffer : Memory, start : Int) -> Int
  /// Upper bound on the number of bytes written
  count(value : Self) -> Int
}

///|
pub impl[T : BigEndianFormat] Format for BigEndian[T] with write(
  value,
  buffer,
  start,
) {
  T::write(value.0, buffer, start)
}

///|
pub impl[T : BigEndianFormat] Format for BigEndian[T] with count(self) {
  T::count(self.0)
}

///|
pub(all) struct LittleEndian[T](T)

///|
/// if contract is violated, behavior is undefined
pub(open) trait LittleEndianFormat {
  /// Write the `value` into `buffer` as the `start` position,
  /// and return the number of bytes written.
  ///
  /// The number of bytes written must not exceed count().
  write(value : Self, buffer : Memory, start : Int) -> Int
  /// Upper bound on the number of bytes written
  count(value : Self) -> Int
}

///|
pub impl[T : LittleEndianFormat] Format for LittleEndian[T] with write(
  value,
  buffer,
  start,
) {
  T::write(value.0, buffer, start)
}

///|
pub impl[T : LittleEndianFormat] Format for LittleEndian[T] with count(self) {
  T::count(self.0)
}
