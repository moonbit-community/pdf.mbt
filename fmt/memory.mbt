///|
struct Memory(FixedArray[Byte])

///|
pub fn Memory::op_get(self : Memory, index : Int) -> Byte = "%fixedarray.unsafe_get"

///|
pub fn Memory::op_set(self : Memory, index : Int, value : Byte) -> Unit = "%fixedarray.unsafe_set"

///|
pub fn Memory::length(self : Memory) -> Int = "%fixedarray.length"

///|
pub fn Memory::make(len : Int, init : Byte) -> Memory = "%fixedarray.make"
