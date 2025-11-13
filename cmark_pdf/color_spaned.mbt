///|
struct ColorSpaned {
  text : Bytes
  style : TokenStyle
} derive(Show, ToJson)

///|
fn token_to_color_style(tok : @tokens.Token) -> TokenStyle {
  match tok {
    // Keywords - language reserved words
    FALSE
    | TRUE
    | PUB
    | PRIV
    | READONLY
    | IMPORT
    | EXTERN
    | BREAK
    | CONTINUE
    | STRUCT
    | ENUM
    | TRAIT
    | DERIVE
    | IMPL
    | WITH
    | RAISE
    | THROW
    | TRY
    | CATCH
    | ASYNC
    | TYPEALIAS
    | TRAITALIAS
    | FNALIAS
    | AS
    | FN
    | IF
    | LET
    | CONST
    | MATCH
    | USING
    | MUTABLE
    | TYPE
    | WHILE
    | RETURN
    | TEST
    | LOOP
    | GUARD
    | DEFER
    | FOR
    | IN
    | IS
    | SUBERROR
    | AND
    | LETREC
    | ENUMVIEW
    | NORAISE
    | TRY_QUESTION
    | TRY_EXCLAMATION
    | ELSE
    | PIPE => Keyword

    // Numbers - all numeric literals
    INT(_) | BYTE(_) | FLOAT(_) | DOUBLE(_) => Num

    // Strings - all string-like literals
    CHAR(_)
    | STRING(_)
    | BYTES(_)
    | MULTILINE_STRING(_)
    | MULTILINE_INTERP(_)
    | INTERP(_) => Str

    // Everything else - identifiers, operators, punctuation, etc.
    _ => Other
  }
}

///|
fn color_style_to_rgb(style : TokenStyle) -> (Double, Double, Double) {
  match style {
    Keyword => (0, 0, 1) // Blue
    Num => (1, 0, 1) // Magenta
    Str => (1, 0, 0) // Dark Red
    Other => (0, 0, 0) // Black
  }
}

///|
fn from_cmark_code_block(block : @cmark.CodeBlock) -> Array[Array[ColorSpaned]] {
  let cs_lines = []
  for line in block.code {
    let tokens = @lexer.tokens_from_string(line.v, comment=false).tokens
    let cs_line = []
    let mut prev_col = 0
    for token in tokens {
      let (token, start, end) = token
      let start = start.cnum
      let end = end.cnum
      let s = try! line.v[start:end]
      // DOT_* token ignore the leading `.`, here we use a workaround
      // https://github.com/moonbitlang/parser/issues/77
      let dot = match token {
        DOT_INT(_) | DOT_LIDENT(_) | DOT_UIDENT(_) => b"."
        _ => b""
      }
      let bytes = Bytes::make(start - prev_col - dot.length(), ' ') +
        dot +
        pdf_bytes_of_string(s.to_string())
      let style = token_to_color_style(token)
      let cs = ColorSpaned::{ text: bytes, style }
      cs_line.push(cs)
      prev_col = end
    }
    cs_lines.push(cs_line)
  }
  cs_lines
}
