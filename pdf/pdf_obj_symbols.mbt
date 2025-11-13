///|
/// parser symbol include terminals and non-terminals
/// 
/// terminal symbols are called `Token` in lexer
/// 
/// here we make MoonBit type corresponding to parser symbol names for simplicity
/// 
///

///|
/// terminal symbols
/// 
///

///|
/// Terminal symbol: Left parenthesis '('
pub type LEFT_PARENTHESIS

///|
/// Terminal symbol: Right parenthesis ')'
pub type RIGHT_PARENTHESIS

///|
/// Terminal symbol: Left curly brace '{'
pub type LEFT_CURLY_BRACE

///|
/// Terminal symbol: Right curly brace '}'
pub type RIGHT_CURLY_BRACE

///|
/// Terminal symbol: Left square bracket '['
pub type LEFT_SQUARE_BRACKET

///|
/// Terminal symbol: Right square bracket ']'
pub type RIGHT_SQUARE_BRACKET

///|
/// Terminal symbol:  
pub(all) struct INDIRECT {
  object_num : Int
  generation_num : Int
}

///|
/// Terminal symbol: Less than sign '<'
pub type LESS_THAN_SIGN

///|
/// Terminal symbol: Greater than sign '>'
pub type GREATER_THAN_SIGN

///|
/// Terminal symbol: Solidus '/'
pub type SOLIDUS

///|
/// Terminal symbol: Dictionary begin marker
pub type DICT_BEGIN

///|
/// Terminal symbol: Dictionary end marker
pub type DICT_END

///|
/// Terminal symbol: Boolean true literal
pub type TRUE

///|
/// Terminal symbol: Boolean false literal
pub type FALSE

///|
/// Terminal symbol: End of file marker
pub type EOF

///|
/// Non-terminal symbol: Object represented as Atom
pub typealias Object as Atom

///|
/// Terminal symbol: Null value literal
pub type NULL

///|
/// Non-terminal symbol: Integer represented as Int
pub typealias Int as INTEGER

///|
/// Non-terminal symbol: Real number represented as Double
pub typealias Double as REAL

///|
/// Non-terminal symbol: String represented as Bytes
pub typealias Bytes as STRING

///|
/// Non-terminal symbol: Name represented as Bytes
pub typealias Bytes as NAME

///|
pub typealias Object as PDF_Array

///|
pub typealias Object as PDF_Dict

///|
pub type DictEntries = Array[(NAME, Object)]

///|
pub typealias Object as PDF_Obj

///|
pub typealias Bytes as STREAM_BYTES

///|
pub typealias PDF_Obj as PDF_Stream

///|
pub type PDF_ArrayEntries = Array[Object]
