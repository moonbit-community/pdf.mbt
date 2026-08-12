///|
struct Memory(FixedArray[Byte])

///|
#alias("_[_]")
pub fn Memory::get(self : Memory, index : Int) -> Byte = "%fixedarray.unsafe_get"

///|
#alias("_[_]=_")
pub fn Memory::set(self : Memory, index : Int, value : Byte) -> Unit = "%fixedarray.unsafe_set"

///|
pub fn Memory::length(self : Memory) -> Int = "%fixedarray.length"

///|
pub fn Memory::make(len : Int, init : Byte) -> Memory = "%fixedarray.make"
