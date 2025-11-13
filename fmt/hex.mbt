///|
pub(all) struct HexLower[T](T)

///|
/// if contract is violated, behavior is undefined
pub(open) trait HexLowerFormat {
  /// Write the `value` into `buffer` as the `start` position,
  /// and return the number of bytes written.
  ///
  /// The number of bytes written must not exceed count().
  write(value : Self, buffer : Memory, start : Int) -> Int
  /// Upper bound on the number of bytes written
  count(value : Self) -> Int
}

///|
pub impl[T : HexLowerFormat] Format for HexLower[T] with write(
  value,
  buffer,
  start,
) {
  T::write(value.0, buffer, start)
}

///|
pub impl[T : HexLowerFormat] Format for HexLower[T] with count(self) {
  T::count(self.0)
}

///|
pub(all) struct HexUpper[T](T)

///|
/// if contract is violated, behavior is undefined
pub(open) trait HexUpperFormat {
  /// Write the `value` into `buffer` as the `start` position,
  /// and return the number of bytes written.
  ///
  /// The number of bytes written must not exceed count().
  write(value : Self, buffer : Memory, start : Int) -> Int
  /// Upper bound on the number of bytes written
  count(value : Self) -> Int
}

///|
pub impl[T : HexUpperFormat] Format for HexUpper[T] with write(
  value,
  buffer,
  start,
) {
  T::write(value.0, buffer, start)
}

///|
pub impl[T : HexUpperFormat] Format for HexUpper[T] with count(self) {
  T::count(self.0)
}
