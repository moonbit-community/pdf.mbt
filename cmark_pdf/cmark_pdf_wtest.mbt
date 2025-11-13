///|
test "array_README" (t : @test.Test) {
  let full_path = "./resources/markdown/array_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/array_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="array_README.pdf.bytes")
}

///|
test "bench_README" (t : @test.Test) {
  let full_path = "./resources/markdown/bench_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/bench_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="bench_README.pdf.bytes")
}

///|
test "bigint_README" (t : @test.Test) {
  let full_path = "./resources/markdown/bigint_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/bigint_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="bigint_README.pdf.bytes")
}

///|
test "bool_README" (t : @test.Test) {
  let full_path = "./resources/markdown/bool_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/bool_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="bool_README.pdf.bytes")
}

///|
test "buffer_README" (t : @test.Test) {
  let full_path = "./resources/markdown/buffer_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/buffer_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="buffer_README.pdf.bytes")
}

///|
test "builtin_README" (t : @test.Test) {
  let full_path = "./resources/markdown/builtin_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/builtin_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="builtin_README.pdf.bytes")
}

///|
test "byte_README" (t : @test.Test) {
  let full_path = "./resources/markdown/byte_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/byte_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="byte_README.pdf.bytes")
}

///|
test "bytes_README" (t : @test.Test) {
  let full_path = "./resources/markdown/bytes_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/bytes_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="bytes_README.pdf.bytes")
}

///|
test "char_README" (t : @test.Test) {
  let full_path = "./resources/markdown/char_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/char_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="char_README.pdf.bytes")
}

///|
test "cmp_README" (t : @test.Test) {
  let full_path = "./resources/markdown/cmp_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/cmp_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="cmp_README.pdf.bytes")
}

///|
test "coverage_README" (t : @test.Test) {
  let full_path = "./resources/markdown/coverage_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/coverage_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="coverage_README.pdf.bytes")
}

///|
test "deque_README" (t : @test.Test) {
  let full_path = "./resources/markdown/deque_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/deque_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="deque_README.pdf.bytes")
}

///|
test "double_README" (t : @test.Test) {
  let full_path = "./resources/markdown/double_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/double_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="double_README.pdf.bytes")
}

///|
test "env_README" (t : @test.Test) {
  let full_path = "./resources/markdown/env_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/env_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="env_README.pdf.bytes")
}

///|
test "error_README" (t : @test.Test) {
  let full_path = "./resources/markdown/error_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/error_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="error_README.pdf.bytes")
}

///|
test "float_README" (t : @test.Test) {
  let full_path = "./resources/markdown/float_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/float_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="float_README.pdf.bytes")
}

///|
test "hashmap_README" (t : @test.Test) {
  let full_path = "./resources/markdown/hashmap_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/hashmap_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="hashmap_README.pdf.bytes")
}

///|
test "hashset_README" (t : @test.Test) {
  let full_path = "./resources/markdown/hashset_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/hashset_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="hashset_README.pdf.bytes")
}

///|
test "int16_README" (t : @test.Test) {
  let full_path = "./resources/markdown/int16_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/int16_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="int16_README.pdf.bytes")
}

///|
test "int64_README" (t : @test.Test) {
  let full_path = "./resources/markdown/int64_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/int64_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="int64_README.pdf.bytes")
}

///|
test "int_README" (t : @test.Test) {
  let full_path = "./resources/markdown/int_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/int_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="int_README.pdf.bytes")
}

///|
test "json_README" (t : @test.Test) {
  let full_path = "./resources/markdown/json_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/json_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="json_README.pdf.bytes")
}

///|
test "list_README" (t : @test.Test) {
  let full_path = "./resources/markdown/list_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/list_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="list_README.pdf.bytes")
}

///|
test "math_README" (t : @test.Test) {
  let full_path = "./resources/markdown/math_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/math_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="math_README.pdf.bytes")
}

///|
test "option_README" (t : @test.Test) {
  let full_path = "./resources/markdown/option_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/option_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="option_README.pdf.bytes")
}

///|
test "priority_queue_README" (t : @test.Test) {
  let full_path = "./resources/markdown/priority_queue_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/priority_queue_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="priority_queue_README.pdf.bytes")
}

///|
test "queue_README" (t : @test.Test) {
  let full_path = "./resources/markdown/queue_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/queue_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="queue_README.pdf.bytes")
}

///|
test "quickcheck_README" (t : @test.Test) {
  let full_path = "./resources/markdown/quickcheck_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/quickcheck_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="quickcheck_README.pdf.bytes")
}

///|
test "random_README" (t : @test.Test) {
  let full_path = "./resources/markdown/random_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/random_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="random_README.pdf.bytes")
}

///|
test "rational_README" (t : @test.Test) {
  let full_path = "./resources/markdown/rational_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/rational_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="rational_README.pdf.bytes")
}

///|
test "ref_README" (t : @test.Test) {
  let full_path = "./resources/markdown/ref_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/ref_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="ref_README.pdf.bytes")
}

///|
test "result_README" (t : @test.Test) {
  let full_path = "./resources/markdown/result_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/result_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="result_README.pdf.bytes")
}

///|
test "set_README" (t : @test.Test) {
  let full_path = "./resources/markdown/set_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/set_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="set_README.pdf.bytes")
}

///|
test "sorted_map_README" (t : @test.Test) {
  let full_path = "./resources/markdown/sorted_map_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/sorted_map_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="sorted_map_README.pdf.bytes")
}

///|
test "sorted_set_README" (t : @test.Test) {
  let full_path = "./resources/markdown/sorted_set_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/sorted_set_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="sorted_set_README.pdf.bytes")
}

///|
test "strconv_README" (t : @test.Test) {
  let full_path = "./resources/markdown/strconv_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/strconv_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="strconv_README.pdf.bytes")
}

///|
test "string_README" (t : @test.Test) {
  let full_path = "./resources/markdown/string_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/string_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="string_README.pdf.bytes")
}

///|
test "test_README" (t : @test.Test) {
  let full_path = "./resources/markdown/test_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/test_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="test_README.pdf.bytes")
}

///|
test "tuple_README" (t : @test.Test) {
  let full_path = "./resources/markdown/tuple_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/tuple_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="tuple_README.pdf.bytes")
}

///|
test "uint16_README" (t : @test.Test) {
  let full_path = "./resources/markdown/uint16_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/uint16_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="uint16_README.pdf.bytes")
}

///|
test "uint64_README" (t : @test.Test) {
  let full_path = "./resources/markdown/uint64_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/uint64_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="uint64_README.pdf.bytes")
}

///|
test "uint_README" (t : @test.Test) {
  let full_path = "./resources/markdown/uint_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/uint_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="uint_README.pdf.bytes")
}

///|
test "unit_README" (t : @test.Test) {
  let full_path = "./resources/markdown/unit_README.md"
  let content = @fs.read_file_to_string(full_path)
  let bytes = markdown_to_bytes(content)
  let path = "./output/unit_README.pdf"
  @fs.write_bytes_to_file(path, bytes)
  inspect(bytes.length() > 0, content="true")
  t.writeln(bytes)
  t.snapshot(filename="unit_README.pdf.bytes")
}
