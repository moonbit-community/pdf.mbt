///|
/// Test the PDF parser with a simple PDF document
test "parse simple PDF" {
  // Create a minimal valid PDF content using bytes literal  
  let input = b"%PDF-1.4\n1 0 obj\ntrue\nendobj\nxref\n0 2\n0000000000 65535 f \n0000000009 00000 n\ntrailer\n<</Size 2>>\nstartxref\n40\n%%EOF"
  let result = parse_pdf_file(input) // Let errors propagate
  @json.inspect(result, content={
    "major": 1,
    "minor": 4,
    "objects": [["Boolean", true]],
    "trailer": ["Dictionary", [["/Size", ["Integer", 2]]]],
  })

  // test lexer
  let file = @pdf.tokenize_file(input)
  @json.inspect(file, content={
    "value": {
      "header": { "major": 1, "minor": 4 },
      "body": [
        {
          "bytes_offset": 9,
          "object_num": 1,
          "generation_num": 0,
          "obj_bytes": "\\ntrue\\n",
        },
      ],
      "xref_table": {
        "entries": [
          { "bytes_offset": 0, "generation_num": 65535, "state": "Free" },
          { "bytes_offset": 9, "generation_num": 0, "state": "InUse" },
        ],
        "start_num": 0,
      },
      "trailer": "<</Size 2>>",
      "start_xref_pos": 40,
    },
    "start_bytes_offset": 0,
    "end_bytes_offset": 115,
    "rest": "",
  })
  let obj = file.value.body[0]
  @json.inspect(obj, content={
    "bytes_offset": 9,
    "object_num": 1,
    "generation_num": 0,
    "obj_bytes": "\\ntrue\\n",
  })
  let bytes = obj.obj_bytes
  inspect(@pdf.ascii_string_of_bytesview(bytes), content="\\ntrue\\n")
  inspect(
    @pdf.ascii_string_of_bytesview(bytes.to_bytes()),
    content="\\ntrue\\n",
  )
  inspect(
    bytes,
    content=(
      #|b"\x0atrue\x0a"
    ),
  )
  let tokens = @pdf.tokenize(bytes.to_bytes())
  inspect(tokens.length(), content="2")
  inspect(
    tokens,
    content="[(TRUE, {row: 1, col: 0}, {row: 1, col: 4}), (EOF, {row: 2, col: 0}, {row: 2, col: 0})]",
  )
  let result = @pdf.parse(tokens)
  @json.inspect(result, content=["Boolean", true])
}

///|
test {
  let input = try! @fs.read_dir("./output")
  let files = input.map(basename => "./output/\{basename}")
  for file in files {
    let input = try! @fs.read_file_to_bytes(file)
    let result = parse_pdf_file(input)
    ignore(result)
  }
}

///|
test "test for pdfbox dataset" {
  let dir_path = "./resources/pdf_dataset/pdfbox"
  let files = try! @fs.read_dir(dir_path)
  // `ISO 32000-2:2020 (PDF 2.0)`, section 7.5.8 Cross-Reference Streams
  // some files use XRef streams, which is not supported yet.
  // These files will be skipped

  let failed = [
    "AES128ExposedMeta.pdf", "AES256ExposedMeta.pdf", "AESkeylength128.pdf", "AESkeylength256.pdf",
    "AcroFormForMerge-DifferentExportValues.pdf", "AcroFormForMerge-DifferentFieldType.pdf",
    "AcroFormForMerge-DifferentOptions.pdf", "AcroFormForMerge-SameNameNode.pdf",
    "AcroFormForMerge-TextFieldsOnly.pdf", "AcroFormForMerge.pdf", "AcroFormsBasicFields.pdf",
    "AcroFormsRotation.pdf", "AcrobatMerge-DifferentExportValues-WasMaster.pdf",
    "AcrobatMerge-DifferentExportValues.pdf", "AcrobatMerge-DifferentFieldType-WasMaster.pdf",
    "AcrobatMerge-DifferentFieldType.pdf", "AcrobatMerge-DifferentOptions-WasMaster.pdf",
    "AcrobatMerge-DifferentOptions.pdf", "AcrobatMerge-SameMerged.pdf", "AcrobatMerge-SameNameNode.pdf",
    "AcrobatMerge-TextFieldsOnly-SameMerged.pdf", "AlignmentTests.pdf", "AngledExample.pdf",
    "AnnotationTypes.pdf", "CombTest.pdf", "ControlCharacters.pdf", "DifferentDALevels.pdf",
    "F001u_3_7j.pdf", "JBIG2Image.pdf", "JPXTestGrey.pdf", "LICENSE.txt", "MultilineFields.pdf",
    "PDFBOX-2725-878725.pdf", "PDFBOX-3044-010197-p5-ligatures.pdf", "PDFBOX-3053-reduced.pdf",
    "PDFBOX-3061-092465-reduced.pdf", "PDFBOX-3062-005717-p1.pdf", "PDFBOX-3062-N2MOQ7YZICIYGTPLQJAWJ4HLN6CCEMHZ-reduced.pdf",
    "PDFBOX-3067-negativeTf.pdf", "PDFBOX-3123-ADSFWTRB3HBZBZKEVESVTBRZC2MNKZF5_reduced.pdf",
    "PDFBOX-3127-RAU4G6QMOVRYBISJU7R6MOVZCRFUO7P4-VFont.pdf", "PDFBOX-3498-Y5TLCWTIAE3FYDVJTV2TXRZGXLEDUNSW.pdf",
    "PDFBOX-3833-reduced.pdf", "PDFBOX-3835-input-acrobat-wrap.pdf", "PDFBOX-4322-Empty-ToUnicode-reduced.pdf",
    "PDFBOX-4417-001031.pdf", "PDFBOX-4531-bidi-ligature-2.pdf", "PDFBOX-4532-reduced.pdf",
    "PDFBOX-4958.pdf", "PDFBOX-5350-JX57O5E5YG6XM4FZABPULQGTW4OXPCWA-p1-reduced.pdf",
    "PDFBOX-5747-unicode-surrogate-with-diacritic-reduced.pdf", "PDFBOX-5784.pdf",
    "PDFBOX-5797-SO79271803.pdf", "PDFBOX-5838-0024320-reduced.pdf", "PDFBOX-5920-4MQTG6ZXOYSMTQ444KGQOVC6ZFQHWFNY-spaces-reduced.pdf",
    "PDFBOX-5920-Y5U2XZCKG2U6TO3FC36NCGOZECHQA2PY-p39-reduced.pdf", "PDFBOX-6018-099267-p9-OrphanPopups.pdf",
    "PDFBOX-6040-nodeloop.pdf", "PDFBOX-6041-example.pdf", "PDFBOX-6049-ExpectedResult.pdf",
    "PDFBOX-6049-Overlay.pdf", "PDFBOX-6049-Source.pdf", "PDFBOX3812-acrobat-multiline-auto.pdf",
    "PasswordSample-256bit.pdf", "acroform.pdf", "attachment.pdf", "ccitt4-cib-test.pdf",
    "data-000001.pdf", "sign_me_protected.pdf", "source.pdf", "unencrypted.pdf",
  ]
  inspect(failed.length(), content="71")
  let skips = Set::from_array(failed)
  let mut count = 0
  for file in files {
    if skips.contains(file) {
      continue
    }
    let file_path = "\{dir_path}/\{file}"
    let input = try! @fs.read_file_to_bytes(file_path)
    parse_pdf_file(input) |> ignore
    count = count + 1
  }
  inspect(count, content="81")
}

///|
test {
  let file_path = "./resources/pdf_dataset/pdfbox/eu-001.pdf"
  let input = try! @fs.read_file_to_bytes(file_path)
  let result = parse_pdf_file(input)
  ignore(result)
}
