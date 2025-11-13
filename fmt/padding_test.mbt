///|
test "paddint/Left" {
  let buffer = @fmt.Memory::make(1024, b'%')
  fn str(data : &@fmt.Format) -> String {
    fill_marker(buffer)
    let count = @fmt.Format::write(data, buffer, 1)
    memory_to_string(buffer, count + 2)
  }

  // Original test - basic left padding with space
  inspect(
    str(@fmt.Left(123456789, width=10, padding=b' ')),
    content="% 123456789%",
  )

  // Test with different padding characters
  inspect(str(@fmt.Left(42, width=5, padding=b'0')), content="%00042%")
  inspect(str(@fmt.Left(123, width=8, padding=b'*')), content="%*****123%")
  inspect(str(@fmt.Left(100, width=6, padding=b'-')), content="%---100%")

  // Test with exact width (no padding needed)
  inspect(str(@fmt.Left(12345, width=5, padding=b' ')), content="%12345%")

  // Test with width smaller than content (no padding)
  inspect(
    str(@fmt.Left(123456789, width=5, padding=b' ')),
    content="%123456789%",
  )

  // Test with single byte
  inspect(str(@fmt.Left(b'X', width=4, padding=b' ')), content="%   X%")

  // Test with zero width
  inspect(str(@fmt.Left(42, width=0, padding=b' ')), content="%42%")

  // Test with different data types
  inspect(str(@fmt.Left(42, width=6, padding=b'0')), content="%000042%")
  inspect(str(@fmt.Left(3.14, width=8, padding=b' ')), content="%    3.14%")
  inspect(str(@fmt.Left(-123, width=7, padding=b' ')), content="%   -123%")

  // Test with bytes content
  inspect(str(@fmt.Left(b"hi", width=5, padding=b'#')), content="%###hi%")

  // Test with larger padding width
  inspect(str(@fmt.Left(b'X', width=10, padding=b'.')), content="%.........X%")

  // Test with UInt type
  inspect(str(@fmt.Left(42U, width=6, padding=b'0')), content="%000042%")

  // Test with negative numbers and different padding
  inspect(str(@fmt.Left(-999, width=8, padding=b'_')), content="%____-999%")

  // Test with very small positive number
  inspect(str(@fmt.Left(7, width=5, padding=b'*')), content="%****7%")

  // Test with bytes view
  inspect(
    str(@fmt.Left(b"test"[0:2], width=6, padding=b'=')),
    content="%====te%",
  )

  // Test count method for different scenarios
  inspect(
    @fmt.Format::count(@fmt.Left(123, width=10, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Left(123456789, width=5, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Left(12345, width=5, padding=b' ')),
    content="11",
  )

  // Test with tuple (composite type that implements Format)
  inspect(
    str(@fmt.Left((42, 100), width=12, padding=b' ')),
    content="%    (42,100)%",
  )

  // Test edge case: width of 1 with single digit
  inspect(str(@fmt.Left(5, width=1, padding=b'0')), content="%5%")

  // Test with double precision numbers
  inspect(str(@fmt.Left(1.5, width=6, padding=b'0')), content="%0001.5%")
}

///|
test "padding/right" {
  let buffer = @fmt.Memory::make(1024, b'%')
  fn str(data : &@fmt.Format) -> String {
    fill_marker(buffer)
    let count = @fmt.Format::write(data, buffer, 1)
    memory_to_string(buffer, count + 2)
  }

  // Original test - basic right padding with space
  inspect(
    str(@fmt.Right(123456789, width=10, padding=b' ')),
    content="%123456789 %",
  )

  // Test with different padding characters
  inspect(str(@fmt.Right(42, width=5, padding=b'0')), content="%42000%")
  inspect(str(@fmt.Right(123, width=8, padding=b'*')), content="%123*****%")
  inspect(str(@fmt.Right(100, width=6, padding=b'-')), content="%100---%")

  // Test with exact width (no padding needed)
  inspect(str(@fmt.Right(12345, width=5, padding=b' ')), content="%12345%")

  // Test with width smaller than content (no padding)
  inspect(
    str(@fmt.Right(123456789, width=5, padding=b' ')),
    content="%123456789%",
  )

  // Test with single byte
  inspect(str(@fmt.Right(b'X', width=4, padding=b' ')), content="%X   %")

  // Test with zero width
  inspect(str(@fmt.Right(42, width=0, padding=b' ')), content="%42%")

  // Test with different data types
  inspect(str(@fmt.Right(42, width=6, padding=b'0')), content="%420000%")
  inspect(str(@fmt.Right(3.14, width=8, padding=b' ')), content="%3.14    %")
  inspect(str(@fmt.Right(-123, width=7, padding=b' ')), content="%-123   %")

  // Test with bytes content
  inspect(str(@fmt.Right(b"hi", width=5, padding=b'#')), content="%hi###%")

  // Test with larger padding width
  inspect(str(@fmt.Right(b'X', width=10, padding=b'.')), content="%X.........%")

  // Test with UInt type
  inspect(str(@fmt.Right(42U, width=6, padding=b'0')), content="%420000%")

  // Test with negative numbers and different padding
  inspect(str(@fmt.Right(-999, width=8, padding=b'_')), content="%-999____%")

  // Test with very small positive number
  inspect(str(@fmt.Right(7, width=5, padding=b'*')), content="%7****%")

  // Test with bytes view
  inspect(
    str(@fmt.Right(b"test"[0:2], width=6, padding=b'=')),
    content="%te====%",
  )

  // Test count method for different scenarios
  inspect(
    @fmt.Format::count(@fmt.Right(123, width=10, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Right(123456789, width=5, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Right(12345, width=5, padding=b' ')),
    content="11",
  )

  // Test with tuple (composite type that implements Format)
  inspect(
    str(@fmt.Right((42, 100), width=12, padding=b' ')),
    content="%(42,100)    %",
  )

  // Test edge case: width of 1 with single digit
  inspect(str(@fmt.Right(5, width=1, padding=b'0')), content="%5%")

  // Test with double precision numbers
  inspect(str(@fmt.Right(1.5, width=6, padding=b'0')), content="%1.5000%")
}

///|
test "padding/Center" {
  let buffer = @fmt.Memory::make(1024, b'%')
  fn str(data : &@fmt.Format) -> String {
    fill_marker(buffer)
    let count = @fmt.Format::write(data, buffer, 1)
    memory_to_string(buffer, count + 2)
  }

  // Original test - basic center padding with space
  inspect(
    str(@fmt.Center(123456789, width=10, padding=b' ')),
    content="%123456789 %",
  )

  // Test with different padding characters
  inspect(str(@fmt.Center(42, width=5, padding=b'0')), content="%04200%")
  inspect(str(@fmt.Center(123, width=8, padding=b'*')), content="%**123***%")
  inspect(str(@fmt.Center(100, width=6, padding=b'-')), content="%-100--%")

  // Test with exact width (no padding needed)
  inspect(str(@fmt.Center(12345, width=5, padding=b' ')), content="%12345%")

  // Test with width smaller than content (no padding)
  inspect(
    str(@fmt.Center(123456789, width=5, padding=b' ')),
    content="%123456789%",
  )

  // Test with single byte
  inspect(str(@fmt.Center(b'X', width=4, padding=b' ')), content="% X  %")

  // Test with zero width
  inspect(str(@fmt.Center(42, width=0, padding=b' ')), content="%42%")

  // Test with different data types
  inspect(str(@fmt.Center(42, width=6, padding=b'0')), content="%004200%")
  inspect(str(@fmt.Center(3.14, width=8, padding=b' ')), content="%  3.14  %")
  inspect(str(@fmt.Center(-123, width=7, padding=b' ')), content="% -123  %")

  // Test with bytes content
  inspect(str(@fmt.Center(b"hi", width=5, padding=b'#')), content="%#hi##%")

  // Test with larger padding width
  inspect(
    str(@fmt.Center(b'X', width=10, padding=b'.')),
    content="%....X.....%",
  )

  // Test with UInt type
  inspect(str(@fmt.Center(42U, width=6, padding=b'0')), content="%004200%")

  // Test with negative numbers and different padding
  inspect(str(@fmt.Center(-999, width=8, padding=b'_')), content="%__-999__%")

  // Test with very small positive number
  inspect(str(@fmt.Center(7, width=5, padding=b'*')), content="%**7**%")

  // Test with bytes view
  inspect(
    str(@fmt.Center(b"test"[0:2], width=6, padding=b'=')),
    content="%==te==%",
  )

  // Test count method for different scenarios
  inspect(
    @fmt.Format::count(@fmt.Center(123, width=10, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Center(123456789, width=5, padding=b' ')),
    content="11",
  )
  inspect(
    @fmt.Format::count(@fmt.Center(12345, width=5, padding=b' ')),
    content="11",
  )

  // Test with tuple (composite type that implements Format)
  inspect(
    str(@fmt.Center((42, 100), width=12, padding=b' ')),
    content="%  (42,100)  %",
  )

  // Test edge case: width of 1 with single digit
  inspect(str(@fmt.Center(5, width=1, padding=b'0')), content="%5%")

  // Test with double precision numbers
  inspect(str(@fmt.Center(1.5, width=6, padding=b'0')), content="%01.500%")

  // Test odd vs even padding distribution
  inspect(str(@fmt.Center(b'A', width=7, padding=b'.')), content="%...A...%")
  inspect(str(@fmt.Center(b'A', width=6, padding=b'.')), content="%..A...%")
}
