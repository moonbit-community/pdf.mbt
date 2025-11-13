///|
pub struct Position {
  row : Int
  col : Int
} derive(Show, ToJson, @json.FromJson)

///|
pub impl Show for Token with output(self, logger) {
  match self {
    LEFT_PARENTHESIS => logger.write_string("LEFT_PARENTHESIS")
    RIGHT_PARENTHESIS => logger.write_string("RIGHT_PARENTHESIS")
    LEFT_CURLY_BRACE => logger.write_string("LEFT_CURLY_BRACE")
    RIGHT_CURLY_BRACE => logger.write_string("RIGHT_CURLY_BRACE")
    LEFT_SQUARE_BRACKET => logger.write_string("LEFT_SQUARE_BRACKET")
    RIGHT_SQUARE_BRACKET => logger.write_string("RIGHT_SQUARE_BRACKET")
    LESS_THAN_SIGN => logger.write_string("LESS_THAN_SIGN")
    GREATER_THAN_SIGN => logger.write_string("GREATER_THAN_SIGN")
    SOLIDUS => logger.write_string("SOLIDUS")
    DICT_BEGIN => logger.write_string("DICT_BEGIN")
    DICT_END => logger.write_string("DICT_END")
    TRUE => logger.write_string("TRUE")
    FALSE => logger.write_string("FALSE")
    INTEGER(value) => {
      logger.write_string("INTEGER(")
      logger.write_string(value.to_string())
      logger.write_string(")")
    }
    REAL(value) => {
      logger.write_string("REAL(")
      logger.write_string(value.to_string())
      logger.write_string(")")
    }
    STRING(value) => {
      logger.write_string("STRING(")
      logger.write_string(value |> ascii_string_of_bytesview)
      logger.write_string(")")
    }
    NAME(value) => {
      logger.write_string("NAME(")
      logger.write_string(value |> ascii_string_of_bytesview)
      logger.write_string(")")
    }
    INDIRECT(value) => {
      logger.write_string("INDIRECT(")
      logger.write_string(value.object_num.to_string())
      logger.write_string(", ")
      logger.write_string(value.generation_num.to_string())
      logger.write_string(")")
    }
    EOF => logger.write_string("EOF")
    NULL => logger.write_string("NULL")
    STREAM_BYTES(stream_bytes) => {
      logger.write_string("STREAM_BYTES(")
      logger.write_string(stream_bytes |> ascii_string_of_bytesview)
      logger.write_string(")")
    }
  }
}
