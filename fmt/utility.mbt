/// private utility functions for memory manipulation

///|
fn memory_copy_forward(
  dst~ : Memory,
  dst_start~ : Int,
  src~ : Memory,
  src_start~ : Int,
  len~ : Int,
) -> Unit {
  let dst_end = dst_start + len
  for dst_ofs = dst_start, src_ofs = src_start
      dst_ofs < dst_end
      dst_ofs = dst_ofs + 1, src_ofs = src_ofs + 1 {
    dst[dst_ofs] = src[src_ofs]
  }
}

///|
fn memory_copy_backward(
  dst~ : Memory,
  dst_start~ : Int,
  src~ : Memory,
  src_start~ : Int,
  len~ : Int,
) -> Unit {
  for dst_ofs = dst_start + len - 1, src_ofs = src_start + len - 1
      dst_ofs >= dst_start
      dst_ofs = dst_ofs - 1, src_ofs = src_ofs - 1 {
    dst[dst_ofs] = src[src_ofs]
  }
}

///|
fn memory_fill(
  memory~ : Memory,
  start~ : Int,
  len~ : Int,
  value~ : Byte,
) -> Unit {
  for ofs = start; ofs < start + len; ofs = ofs + 1 {
    memory[ofs] = value
  }
}
