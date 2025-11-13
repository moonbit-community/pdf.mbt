///|
test "ToJson for GraphicOperator" {
  let op1 = Op_w(1.5)
  let json1 = op1.to_json()
  @json.inspect(json1, content={ "op": "w", "width": 1.5 })
  let op2 = Op_Tj(b"Hello World")
  let json2 = op2.to_json()
  @json.inspect(json2, content={ "op": "Tj", "text": "Hello World" })
  let op3 = Op_q
  let json3 = op3.to_json()
  @json.inspect(json3, content={ "op": "q" })
}

///|
test "ToJson for File" {
  let file = File::{
    major: 1,
    minor: 7,
    objects: [Object::Null, Object::Boolean(true)],
    trailer: Object::Dictionary([]),
  }
  let json = file.to_json()
  @json.inspect(json, content={
    "major": 1,
    "minor": 7,
    "objects": ["Null", ["Boolean", true]],
    "trailer": ["Dictionary", []],
  })
}

///|
test "ToJson for TransformMatrix" {
  let matrix = TransformMatrix::{
    a: 1.0,
    b: 0.0,
    c: 0.0,
    d: 1.0,
    e: 0.0,
    f: 0.0,
  }
  let json = matrix.to_json()
  @json.inspect(json, content={
    "a": 1.0,
    "b": 0.0,
    "c": 0.0,
    "d": 1.0,
    "e": 0.0,
    "f": 0.0,
  })
}

///|
test "ToJson for ContentStream" {
  let stream = ContentStream([Op_q, Op_w(2.0), Op_Q])
  let json = stream.to_json()
  @json.inspect(json, content={
    "operators": [{ "op": "q" }, { "op": "w", "width": 2.0 }, { "op": "Q" }],
  })
}

///|
test "ToJson for StandardFont" {
  let font1 = TimesRoman
  let json1 = font1.to_json()
  @json.inspect(json1, content="Times-Roman")
  let font2 = HelveticaBold
  let json2 = font2.to_json()
  @json.inspect(json2, content="Helvetica-Bold")
  let font3 = CourierOblique
  let json3 = font3.to_json()
  @json.inspect(json3, content="Courier-Oblique")
}

///|
fn bytes_concat(bs : Array[Bytes]) -> Bytes {
  let buffer = @buffer.new(size_hint=1024)
  for b in bs {
    buffer.write_bytes(b)
  }
  buffer.to_bytes()
}

///|
test "byte_offset" {
  let file_header = b"%PDF-1.4\n"
  let body = [b"1 0 obj\n", b"null\n", b"endobj\n"]
  let xref_table = [
    b"xref\n", b"0 2\n", b"0000000000 65535 f \n", b"000000009 00000 n\n",
  ]
  let trailer = [
    b"trailer\n", b"<</Size 2 /Root 1 0 R>>\n", b"startxref\n", b"29\n", b"%%EOF\n",
  ]
  let file = bytes_concat([file_header, ..body, ..xref_table, ..trailer])
  let result = tokenize_file(file)
  inspect(file_header.length(), content="9")
  inspect(result.value.body[0].start_bytes_offset, content="9")
  inspect(file.length() - result.rest.length(), content="126")
  inspect(result.end_bytes_offset, content="126")
  inspect(result.value.start_xref_bytes_offset, content="29")
  inspect(
    file_header.length() + body.fold(init=0, (acc, x) => acc + x.length()),
    content="29",
  )
  @json.inspect(result, content={
    "value": {
      "header": { "major": 1, "minor": 4 },
      "body": [
        {
          "bytes_offset": 9,
          "object_num": 1,
          "generation_num": 0,
          "obj_bytes": "\\nnull\\n",
        },
      ],
      "xref_table": {
        "entries": [
          { "bytes_offset": 0, "generation_num": 65535, "state": "Free" },
          { "bytes_offset": 9, "generation_num": 0, "state": "InUse" },
        ],
        "start_num": 0,
      },
      "trailer": "<</Size 2 /Root 1 0 R>>",
      "start_xref_pos": 29,
    },
    "start_bytes_offset": 0,
    "end_bytes_offset": 126,
    "rest": "\\n",
  })
}

///|
test "tokenize_file with comments between sections" {
  let pdf_content =
    #|%PDF-1.4
    #|% This is a comment after header
    #|1 0 obj
    #|null
    #|endobj
    #|% Comment after body
    #|xref
    #|0 2
    #|0000000000 65535 f 
    #|0000000009 00000 n
    #|% Comment after xref
    #|trailer
    #|<<
    #|/Size 2
    #|>>
    #|% Comment after trailer
    #|startxref
    #|35
    #|%%EOF
    #|
  let input = @encoding/utf8.encode(pdf_content)
  let result = try? tokenize_file(input)
  @json.inspect(result is Ok(_), content=true)
  match result {
    Ok(file_result) => {
      @json.inspect(file_result.value.header, content={ "major": 1, "minor": 4 })
      @json.inspect(file_result.value.body.length(), content=1)
      @json.inspect(file_result.value.xref_table.entries.length(), content=2)
    }
    Err(_) => fail("Should not have failed to parse")
  }
}

///|
test "tokenize_file without comments" {
  let pdf_content =
    #|%PDF-1.4
    #|1 0 obj
    #|null
    #|endobj
    #|xref
    #|0 2
    #|0000000000 65535 f 
    #|0000000009 00000 n
    #|trailer
    #|<<
    #|/Size 2
    #|>>
    #|startxref
    #|35
    #|%%EOF
    #|
  let input = @encoding/utf8.encode(pdf_content)
  let result = try? tokenize_file(input)
  @json.inspect(result is Ok(_), content=true)
  match result {
    Ok(file_result) => {
      @json.inspect(file_result.value.header, content={ "major": 1, "minor": 4 })
      @json.inspect(file_result.value.body.length(), content=1)
      @json.inspect(file_result.value.xref_table.entries.length(), content=2)
    }
    Err(_) => fail("Should not have failed to parse")
  }
}

///|
test {
  let input = b"4 0 obj \x0a<<\x0a/Border [0 0 0]\x0a/Subtype /Link\x0a/C [0 0 0]\x0a/A \x0a<<\x0a/URI (http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2006:033:0001:0017:EN:PDF#page=8)\x0a/S /URI\x0a>>\x0a/Type /Annot\x0a/Rect [312 719 469 735]\x0a>>\x0aendobj"
  let result = tokenize_body(input, start_bytes_offset=0)
  @json.inspect(result, content={
    "value": [
      {
        "bytes_offset": 0,
        "object_num": 4,
        "generation_num": 0,
        "obj_bytes": " \\n<<\\n/Border [0 0 0]\\n/Subtype /Link\\n/C [0 0 0]\\n/A \\n<<\\n/URI (http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2006:033:0001:0017:EN:PDF#page=8)\\n/S /URI\\n>>\\n/Type /Annot\\n/Rect [312 719 469 735]\\n>>\\n",
      },
    ],
    "start_bytes_offset": 0,
    "end_bytes_offset": 217,
    "rest": "",
  })
  inspect(input.length(), content="217")
}

///|
test {
  let objs = [
    b"1 0 obj\nnull\nendobj\n", b"2 0 obj\n<< /Type /Catalog >>\nendobj\n", b"3 0 obj\n[ 1 2 3 ]\nendobj\n",
  ]
  let input = bytes_concat(objs)
  let result = tokenize_body(input, start_bytes_offset=0)
  let objs_offsets = result.value
    .iter()
    .map(x => x.start_bytes_offset)
    .collect()
  let expected_offsets = array_scanl(objs)(0, (acc, x) => acc + x.length())[0:objs_offsets.length()].to_array()
  assert_eq(objs_offsets, expected_offsets)
  @json.inspect(result, content={
    "value": [
      {
        "bytes_offset": 0,
        "object_num": 1,
        "generation_num": 0,
        "obj_bytes": "\\nnull\\n",
      },
      {
        "bytes_offset": 20,
        "object_num": 2,
        "generation_num": 0,
        "obj_bytes": "\\n<< /Type /Catalog >>\\n",
      },
      {
        "bytes_offset": 56,
        "object_num": 3,
        "generation_num": 0,
        "obj_bytes": "\\n[ 1 2 3 ]\\n",
      },
    ],
    "start_bytes_offset": 0,
    "end_bytes_offset": 81,
    "rest": "",
  })
}

///|
fn[A, B] array_scanl(xs : Array[A]) -> (B, (B, A) -> B) -> Array[B] {
  fn(init : B, f : (B, A) -> B) -> Array[B] {
    let result : Array[B] = Array::new()
    result.push(init)
    let mut acc = init
    for x in xs {
      acc = f(acc, x)
      result.push(acc)
    }
    result
  }
}
