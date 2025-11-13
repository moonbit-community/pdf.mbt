///|
pub(all) enum Left[T] {
  Left(T, width~ : Int, padding~ : Byte)
}

///|
pub impl[T : Format] Format for Left[T] with write(
  value : Left[T],
  buffer : Memory,
  start : Int,
) {
  let Left(value, width~, padding~) = value
  let cnt = Format::write(value, buffer, start)
  let padding_len = width - cnt
  if padding_len > 0 {
    memory_copy_backward(
      dst=buffer,
      dst_start=start + padding_len,
      src=buffer,
      src_start=start,
      len=cnt,
    )
    memory_fill(memory=buffer, start~, len=padding_len, value=padding)
    width
  } else {
    cnt
  }
}

///|
pub impl[T : Format] Format for Left[T] with count(value : Left[T]) {
  let Left(value, width~, ..) = value
  let cnt = Format::count(value)
  if cnt < width {
    width
  } else {
    cnt
  }
}

///|
pub(all) enum Center[T] {
  Center(T, width~ : Int, padding~ : Byte)
}

///|
pub impl[T : Format] Format for Center[T] with write(
  value : Center[T],
  buffer : Memory,
  start : Int,
) {
  let Center(value, width~, padding~) = value
  let cnt = Format::write(value, buffer, start)
  let padding_len = width - cnt
  if padding_len > 0 {
    let left_padding_len = padding_len / 2
    let right_padding_len = padding_len - left_padding_len
    memory_copy_backward(
      dst=buffer,
      dst_start=start + left_padding_len,
      src=buffer,
      src_start=start,
      len=cnt,
    )
    memory_fill(memory=buffer, start~, len=left_padding_len, value=padding)
    memory_fill(
      memory=buffer,
      start=start + left_padding_len + cnt,
      len=right_padding_len,
      value=padding,
    )
    width
  } else {
    cnt
  }
}

///|
pub impl[T : Format] Format for Center[T] with count(value : Center[T]) {
  let Center(value, width~, ..) = value
  let cnt = Format::count(value)
  if cnt < width {
    width
  } else {
    cnt
  }
}

///|
pub(all) enum Right[T] {
  Right(T, width~ : Int, padding~ : Byte)
}

///|
pub impl[T : Format] Format for Right[T] with write(
  value : Right[T],
  buffer : Memory,
  start : Int,
) {
  let Right(value, width~, padding~) = value
  let cnt = Format::write(value, buffer, start)
  let padding_len = width - cnt
  if padding_len > 0 {
    let offset = start + cnt
    memory_fill(memory=buffer, start=offset, len=padding_len, value=padding)
    width
  } else {
    cnt
  }
}

///|
pub impl[T : Format] Format for Right[T] with count(value : Right[T]) {
  let Right(value, width~, ..) = value
  let cnt = Format::count(value)
  if cnt < width {
    width
  } else {
    cnt
  }
}
