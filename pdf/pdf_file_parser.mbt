///|
/// Main parser function that converts raw PDF bytes to a structured PDF file
pub fn parse_pdf_file(input : BytesView) -> File raise {
  // Step 1: Use pdf_file_lexer to tokenize the entire PDF file structure
  let file_result = tokenize_file(input) // Let LexError propagate
  let pdf_file = file_result.value

  // Step 2: Parse each object in the body using pdf_object_parser
  let parsed_objects = []
  for obj in pdf_file.body {
    let parsed_obj = parse_pdf_object(obj.obj_bytes) // Let ParseError propagate
    parsed_objects.push(parsed_obj)
  }

  // Step 3: Parse the trailer dictionary
  let trailer_dict = parse_pdf_object(pdf_file.trailer)

  // Step 4: Construct the final File structure
  File::{
    major: pdf_file.header.major,
    minor: pdf_file.header.minor,
    objects: parsed_objects,
    trailer: trailer_dict,
  }
}

///|
/// Parse a PDF object from its byte representation
fn parse_pdf_object(obj_bytes : BytesView) -> Object raise ParseError {
  // TODO: 
  // lexmatch might has some bug, here use `to_bytes()` as a workaround
  let tokens = tokenize(obj_bytes.to_bytes())
  let parsed_obj = parse(tokens)
  // Let ParseError propagate
   catch {
    UnexpectedToken(lookahead, position, expected) as e => {
      println(obj_bytes)
      println(lookahead)
      println(position)
      println(expected)
      raise e
    }
    e => raise e
  }
  parsed_obj
}
