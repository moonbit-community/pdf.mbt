///|
/// ToJson pub implementation for GraphicOperator
pub impl ToJson for GraphicOperator with to_json(self) {
  match self {
    Op_w(width) => { "op": "w", "width": width }
    Op_J(cap) => { "op": "J", "cap": cap }
    Op_j(join) => { "op": "j", "join": join }
    Op_M(limit) => { "op": "M", "limit": limit }
    Op_d(pattern, phase) => { "op": "d", "pattern": pattern, "phase": phase }
    Op_ri(intent) =>
      { "op": "ri", "intent": ascii_string_of_bytesview(intent[:]) }
    Op_i(flatness) => { "op": "i", "flatness": flatness }
    Op_gs(name) => { "op": "gs", "name": ascii_string_of_bytesview(name[:]) }
    Op_q => { "op": "q" }
    Op_Q => { "op": "Q" }
    Op_cm(matrix) => { "op": "cm", "matrix": matrix }
    Op_m(x, y) => { "op": "m", "x": x, "y": y }
    Op_l(x, y) => { "op": "l", "x": x, "y": y }
    Op_c(x1, y1, x2, y2, x3, y3) =>
      { "op": "c", "x1": x1, "y1": y1, "x2": x2, "y2": y2, "x3": x3, "y3": y3 }
    Op_v(x2, y2, x3, y3) =>
      { "op": "v", "x2": x2, "y2": y2, "x3": x3, "y3": y3 }
    Op_y(x1, y1, x3, y3) =>
      { "op": "y", "x1": x1, "y1": y1, "x3": x3, "y3": y3 }
    Op_h => { "op": "h" }
    Op_re(x, y, width, height) =>
      { "op": "re", "x": x, "y": y, "width": width, "height": height }
    Op_S => { "op": "S" }
    Op_s => { "op": "s" }
    Op_f => { "op": "f" }
    Op_F => { "op": "F" }
    Op_f_star => { "op": "f*" }
    Op_B => { "op": "B" }
    Op_B_star => { "op": "B*" }
    Op_b => { "op": "b" }
    Op_b_star => { "op": "b*" }
    Op_n => { "op": "n" }
    Op_W => { "op": "W" }
    Op_W_star => { "op": "W*" }
    Op_BT => { "op": "BT" }
    Op_ET => { "op": "ET" }
    Op_Tc(spacing) => { "op": "Tc", "spacing": spacing }
    Op_Tw(spacing) => { "op": "Tw", "spacing": spacing }
    Op_Tz(scale) => { "op": "Tz", "scale": scale }
    Op_TL(leading) => { "op": "TL", "leading": leading }
    Op_Tf(font, size) =>
      { "op": "Tf", "font": ascii_string_of_bytesview(font[:]), "size": size }
    Op_Tr(mode) => { "op": "Tr", "mode": mode }
    Op_Ts(rise) => { "op": "Ts", "rise": rise }
    Op_Td(x, y) => { "op": "Td", "x": x, "y": y }
    Op_TD(x, y) => { "op": "TD", "x": x, "y": y }
    Op_Tm(matrix) => { "op": "Tm", "matrix": matrix }
    Op_T_star => { "op": "T*" }
    Op_Tj(text) => { "op": "Tj", "text": ascii_string_of_bytesview(text[:]) }
    Op_TJ(array) => { "op": "TJ", "array": array }
    Op_single_quote(text) =>
      { "op": "'", "text": ascii_string_of_bytesview(text[:]) }
    Op_double_quote(w, c, text) =>
      {
        "op": "\"",
        "word_spacing": w,
        "char_spacing": c,
        "text": ascii_string_of_bytesview(text[:]),
      }
    Op_d0(x, y) => { "op": "d0", "x": x, "y": y }
    Op_d1(x, y, llx, lly, urx, ury) =>
      {
        "op": "d1",
        "x": x,
        "y": y,
        "llx": llx,
        "lly": lly,
        "urx": urx,
        "ury": ury,
      }
    Op_CS(name) => { "op": "CS", "name": ascii_string_of_bytesview(name[:]) }
    Op_cs(name) => { "op": "cs", "name": ascii_string_of_bytesview(name[:]) }
    Op_SC(values) => { "op": "SC", "values": values }
    Op_sc(values) => { "op": "sc", "values": values }
    Op_SCN(values) => { "op": "SCN", "values": values }
    Op_scn(values) => { "op": "scn", "values": values }
    Op_SCNName(name, values) =>
      {
        "op": "SCN",
        "name": ascii_string_of_bytesview(name[:]),
        "values": values,
      }
    Op_scnName(name, values) =>
      {
        "op": "scn",
        "name": ascii_string_of_bytesview(name[:]),
        "values": values,
      }
    Op_G(gray) => { "op": "G", "gray": gray }
    Op_g(gray) => { "op": "g", "gray": gray }
    Op_RG(r, g, b) => { "op": "RG", "r": r, "g": g, "b": b }
    Op_rg(r, g, b) => { "op": "rg", "r": r, "g": g, "b": b }
    Op_K(c, m, y, k) => { "op": "K", "c": c, "m": m, "y": y, "k": k }
    Op_k(c, m, y, k) => { "op": "k", "c": c, "m": m, "y": y, "k": k }
    Op_sh(name) => { "op": "sh", "name": ascii_string_of_bytesview(name[:]) }
    InlineImage(dict, data) =>
      {
        "op": "BI/ID/EI",
        "dict": dict,
        "data": ascii_string_of_bytesview(data[:]),
      }
    Op_Do(name) => { "op": "Do", "name": ascii_string_of_bytesview(name[:]) }
    Op_MP(tag) => { "op": "MP", "tag": ascii_string_of_bytesview(tag[:]) }
    Op_DP(tag, properties) =>
      {
        "op": "DP",
        "tag": ascii_string_of_bytesview(tag[:]),
        "properties": properties,
      }
    Op_BMC(tag) => { "op": "BMC", "tag": ascii_string_of_bytesview(tag[:]) }
    Op_BDC(tag, properties) =>
      {
        "op": "BDC",
        "tag": ascii_string_of_bytesview(tag[:]),
        "properties": properties,
      }
    Op_EMC => { "op": "EMC" }
    Op_BX => { "op": "BX" }
    OP_EX => { "op": "EX" }
    Op_Unknown(data) =>
      { "op": "Unknown", "data": ascii_string_of_bytesview(data[:]) }
    Op_Comment(text) =>
      { "op": "Comment", "text": ascii_string_of_bytesview(text[:]) }
  }
}

///|
/// ToJson pub implementation for File
pub impl ToJson for File with to_json(self) {
  {
    "major": self.major,
    "minor": self.minor,
    "objects": self.objects,
    "trailer": self.trailer,
  }
}

///|
/// ToJson pub implementation for TransformMatrix
pub impl ToJson for TransformMatrix with to_json(self) {
  {
    "a": self.a,
    "b": self.b,
    "c": self.c,
    "d": self.d,
    "e": self.e,
    "f": self.f,
  }
}

///|
/// ToJson pub implementation for ContentStream
pub impl ToJson for ContentStream with to_json(self) {
  { "operators": self.0 }
}

///|
/// ToJson pub implementation for StandardFont
pub impl ToJson for StandardFont with to_json(self) {
  match self {
    TimesRoman => "Times-Roman"
    TimesBold => "Times-Bold"
    TimesItalic => "Times-Italic"
    TimesBoldItalic => "Times-BoldItalic"
    Helvetica => "Helvetica"
    HelveticaBold => "Helvetica-Bold"
    HelveticaOblique => "Helvetica-Oblique"
    HelveticaBoldOblique => "Helvetica-BoldOblique"
    Courier => "Courier"
    CourierBold => "Courier-Bold"
    CourierOblique => "Courier-Oblique"
    CourierBoldOblique => "Courier-BoldOblique"
    Symbol => "Symbol"
    ZapfDingbats => "ZapfDingbats"
  }
}

///|
pub impl ToJson for LexFile with to_json(self) {
  {
    "header": self.header,
    "body": self.body,
    "xref_table": self.xref_table,
    "trailer": ascii_string_of_bytesview(self.trailer),
    "start_xref_pos": self.start_xref_bytes_offset,
  }
}

///|
pub impl ToJson for LexHeader with to_json(self) {
  { "major": self.major, "minor": self.minor }
}

///|
pub impl ToJson for LexObj with to_json(self) {
  {
    "bytes_offset": self.start_bytes_offset,
    "object_num": self.object_num,
    "generation_num": self.generation_num,
    "obj_bytes": ascii_string_of_bytesview(self.obj_bytes),
  }
}

///|
pub impl ToJson for LexBody with to_json(self) {
  self.0.to_json()
}

///|
pub impl ToJson for LexXRefTable with to_json(self) {
  { "entries": self.entries, "start_num": self.start_num }
}

///|
pub impl ToJson for LexXRefEntry with to_json(self) {
  {
    "bytes_offset": self.bytes_offset,
    "generation_num": self.generation_num,
    "state": self.state,
  }
}

///|
pub impl ToJson for LexEntryState with to_json(self) {
  match self {
    InUse => "InUse"
    Free => "Free"
  }
}

///|
test "ToJson implementations" {
  let in_use : LexEntryState = InUse
  let free : LexEntryState = Free
  @json.inspect(in_use, content="InUse")
  @json.inspect(free, content="Free")
  let header : LexHeader = { major: 1, minor: 7 }
  @json.inspect(header, content={ "major": 1, "minor": 7 })
  let entry : LexXRefEntry = {
    bytes_offset: 123,
    generation_num: 0,
    state: InUse,
  }
  @json.inspect(entry, content={
    "bytes_offset": 123,
    "generation_num": 0,
    "state": "InUse",
  })
  let test_bytes = b"Hello PDF"
  let obj : LexObj = {
    start_bytes_offset: 100,
    object_num: 1,
    generation_num: 0,
    obj_bytes: test_bytes[:],
  }
  @json.inspect(obj, content={
    "bytes_offset": 100,
    "object_num": 1,
    "generation_num": 0,
    "obj_bytes": "Hello PDF",
  })
}

///|
pub impl[T : ToJson] ToJson for LexResult[T] with to_json(self) {
  {
    "value": self.value,
    "start_bytes_offset": self.start_bytes_offset,
    "end_bytes_offset": self.end_bytes_offset,
    "rest": ascii_string_of_bytesview(self.rest),
  }
}
