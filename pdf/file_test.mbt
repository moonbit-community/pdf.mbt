///|
test "test write to file" {
  let buffer = @fmt.Memory::make(4096, Byte::default())
  let buf = buffer

  // Use define_pages helper function
  let pages = define_pages(pages=[@pdf.Indirect(4)])
  let offset = @fmt.write(pages, buf, 0)
  inspect(
    string_of_memory(buffer, offset),
    content=(
      #|<<
      #|  /Type /Pages  
      #|  /Kids [4 0 R]  
      #|  /Count 1
      #|>>
    ),
  )
  let tm : @pdf.TransformMatrix = @pdf.TransformMatrix::{
    a: 1,
    b: 0,
    c: 0,
    d: 1,
    e: 50,
    f: 770,
  }
  let op1 = @pdf.Op_cm(tm)
  let op2 = @pdf.Op_BT
  let op3 = @pdf.Op_Tf(b"/F0", 36)
  let op4 = @pdf.Op_Tj(b"Hello, World!")
  let op5 = @pdf.Op_ET
  let content : @pdf.ContentStream = [op1, op2, op3, op4, op5]
  let offset = @fmt.write(content, buf, 0)
  let bytes = bytes_of_memory(buf, offset)
  let len = bytes.length()
  let stm = @pdf.Object::Stream(
    @pdf.Dictionary([("/Length", @pdf.Integer(len))]),
    bytes,
  )
  let offset = @fmt.write(stm, buf, 0)
  inspect(
    string_of_memory(buffer, offset),
    content=(
      #|<<
      #|  /Length 53
      #|>>
      #|stream
      #| 1 0 0 1 50 770 cm BT /F0 36 Tf (Hello, World!) Tj ET
      #|endstream
    ),
  )
}

///|
test {
  let buffer = @fmt.Memory::make(4096, Byte::default())
  let offset = @fmt.format_write(" ET", [], buffer, 0)
  inspect(string_of_memory(buffer, offset), content=" ET")
}

///|
/// 
/// first and last should be indirect references
fn make_outline(first : @pdf.Object, last : @pdf.Object) -> @pdf.Object {
  @pdf.Dictionary([
    ("/Type", @pdf.Name(b"/Outlines")),
    ("/First", first),
    ("/Last", last),
    ("/Count", @pdf.Integer(0)),
  ])
}

///|
fn make_outline_item(
  title~ : Bytes,
  parent~ : @pdf.Object,
  prev~ : @pdf.Object,
  next~ : @pdf.Object,
  first~ : @pdf.Object,
  last~ : @pdf.Object,
) -> @pdf.Object {
  @pdf.Dictionary([
    ("/Title", @pdf.String(title)),
    ("/Parent", parent),
    ("/Prev", prev),
    ("/Next", next),
    ("/First", first),
    ("/Last", last),
    ("/Count", @pdf.Integer(0)),
  ])
}

///|
fn define_catalog(pages~ : @pdf.Object, outlines~ : @pdf.Object) -> @pdf.Object {
  Dictionary([
    ("/Type", Name("/Catalog")),
    ("/Pages", pages),
    ("/Outlines", outlines),
  ])
}

///|
struct Tree {
  title : String
  children : Array[Tree]
} derive(Show, ToJson)

///|
struct TreeWithIndex {
  title : String
  index : Int
  children : Array[TreeWithIndex]
} derive(Show, ToJson)

///|
fn TreeWithIndex::from(tree : Tree, start_index : Int) -> TreeWithIndex {
  let mut index = start_index - 1
  // depth first search
  // pre-order traversal
  fn dfs(root : Tree) -> TreeWithIndex {
    index = index + 1
    TreeWithIndex::{
      title: root.title,
      index,
      children: root.children.map(dfs),
    }
  }

  dfs(tree)
}

///|
fn TreeWithIndex::to_outline_item(
  self : TreeWithIndex,
  parent : Int,
) -> Array[(Int, @pdf.Object)] {
  let items = []
  fn dfs(
    root : TreeWithIndex,
    parent : Int,
    prev : @pdf.Object,
    next : @pdf.Object,
  ) -> Unit {
    let len = root.children.length()

    // Create outline item for current node
    let first = if len == 0 {
      @pdf.Null
    } else {
      @pdf.Indirect(root.children[0].index)
    }
    let last = if len == 0 {
      @pdf.Null
    } else {
      @pdf.Indirect(root.children[len - 1].index)
    }
    let outline_item = make_outline_item(
      title=@encoding/utf8.encode(root.title),
      parent=@pdf.Indirect(parent),
      prev~,
      next~,
      first~,
      last~,
    )
    items.push((root.index, outline_item))

    // Process children with proper prev/next relationships
    for i = 0; i < len; i = i + 1 {
      let child = root.children[i]
      let child_prev = if i == 0 {
        @pdf.Null
      } else {
        @pdf.Indirect(root.children[i - 1].index)
      }
      let child_next = if i == len - 1 {
        @pdf.Null
      } else {
        @pdf.Indirect(root.children[i + 1].index)
      }
      dfs(child, root.index, child_prev, child_next)
    }
  }

  // Start DFS from root with no prev/next (since it's the root)
  dfs(self, parent, @pdf.Null, @pdf.Null)
  items.sort_by_key(x => x.0)
  items
}

///|
test {
  let tree = Tree::{
    title: "chapter 1",
    children: [
      { title: "section 1.1", children: [] },
      {
        title: "section 1.2",
        children: [{ title: "subsection 1.2.1", children: [] }],
      },
    ],
  }
  let _tree_with_index = TreeWithIndex::from(tree, 0)
  let objs = _tree_with_index.to_outline_item(0)
  @json.inspect(objs, content=[
    [
      0,
      [
        "Dictionary",
        [
          ["/Title", ["String", "chapter 1"]],
          ["/Parent", ["Indirect", 0]],
          ["/Prev", "Null"],
          ["/Next", "Null"],
          ["/First", ["Indirect", 1]],
          ["/Last", ["Indirect", 2]],
          ["/Count", ["Integer", 0]],
        ],
      ],
    ],
    [
      1,
      [
        "Dictionary",
        [
          ["/Title", ["String", "section 1.1"]],
          ["/Parent", ["Indirect", 0]],
          ["/Prev", "Null"],
          ["/Next", ["Indirect", 2]],
          ["/First", "Null"],
          ["/Last", "Null"],
          ["/Count", ["Integer", 0]],
        ],
      ],
    ],
    [
      2,
      [
        "Dictionary",
        [
          ["/Title", ["String", "section 1.2"]],
          ["/Parent", ["Indirect", 0]],
          ["/Prev", ["Indirect", 1]],
          ["/Next", "Null"],
          ["/First", ["Indirect", 3]],
          ["/Last", ["Indirect", 3]],
          ["/Count", ["Integer", 0]],
        ],
      ],
    ],
    [
      3,
      [
        "Dictionary",
        [
          ["/Title", ["String", "subsection 1.2.1"]],
          ["/Parent", ["Indirect", 2]],
          ["/Prev", "Null"],
          ["/Next", "Null"],
          ["/First", "Null"],
          ["/Last", "Null"],
          ["/Count", ["Integer", 0]],
        ],
      ],
    ],
  ])
}

///|
test (t : @test.Test) {
  let buffer = @fmt.Memory::make(4096, Byte::default())
  let buf = buffer
  let tm : @pdf.TransformMatrix = @pdf.TransformMatrix::{
    a: 1,
    b: 0,
    c: 0,
    d: 1,
    e: 50,
    f: 770,
  }
  let op1 = @pdf.Op_cm(tm)
  let op2 = @pdf.Op_BT
  let op3 = @pdf.Op_Tf(b"/F0", 36)
  let op4 = @pdf.Op_Tj(b"Hello, World!")
  let op5 = @pdf.Op_ET
  let content : @pdf.ContentStream = [op1, op2, op3, op4, op5]
  let offset = @fmt.write(content, buf, 0)
  inspect(
    string_of_memory(buf, offset),
    content=" 1 0 0 1 50 770 cm BT /F0 36 Tf (Hello, World!) Tj ET",
  )
  let bytes = bytes_of_memory(buf, offset)
  let len = bytes.length()

  // 1 0 obj
  let stm = @pdf.Object::Stream(
    @pdf.Dictionary([("/Length", @pdf.Integer(len))]),
    bytes,
  )
  // 2 0 obj - Use define_pages helper
  let pages = define_pages(pages=[@pdf.Indirect(4)])

  // 3 0 obj - Use define_catalog helper
  let catalog = define_catalog(
    pages=@pdf.Indirect(2),
    outlines=@pdf.Indirect(5),
  )
  let times_italic_font = @pdf.Dictionary([
    ("/Type", @pdf.Name(b"/Font")),
    ("/Subtype", @pdf.Name(b"/Type1")),
    ("/BaseFont", @pdf.Name(b"/Times-Italic")),
  ])
  let font_f0 = define_font_item(name=b"/F0", font=times_italic_font)
  // 4 0 obj - Use define_page and helper functions for resources
  let font_resources = define_fonts(fonts=[font_f0])
  let page = define_page(contents=@pdf.Indirect(1), parent=@pdf.Indirect(2), resources=[
    font_resources,
  ])
  // 5 0 obj - outline dictionary
  let outline = make_outline(@pdf.Indirect(6), @pdf.Indirect(6))
  let tree = Tree::{
    title: "chapter 1",
    children: [
      { title: "section 1.1", children: [] },
      {
        title: "section 1.2",
        children: [{ title: "subsection 1.2.1", children: [] }],
      },
    ],
  }
  let tree_with_index = TreeWithIndex::from(tree, 6)
  let outline_items = tree_with_index.to_outline_item(5).map(x => x.1)
  let pdf = make_pdf(
    @pdf.Indirect(3),
    [stm, pages, catalog, page, outline, ..outline_items],
  )
  let offset = @fmt.write(pdf, buf, 0)
  let pdf_file = bytes_of_memory(buf, offset)
  @fs.write_bytes_to_file("./output/hello.pdf", pdf_file)
  t.writeln(pdf_file)
  t.snapshot(filename="hello.pdf.bytes")
}

///|
test "image" (t : @test.Test) {
  let buffer = @fmt.Memory::make(1_000_000, Byte::default())
  let buf = buffer
  let times = 28.0
  let tm : @pdf.TransformMatrix = @pdf.TransformMatrix::{
    a: 3.6 * times,
    b: 0,
    c: 0,
    d: 1 * times,
    e: 50,
    f: 770,
  }
  let content : @pdf.ContentStream = [@pdf.Op_cm(tm), @pdf.Op_Do(b"/Im0")]
  let offset = @fmt.write(content, buf, 0)
  let bytes = bytes_of_memory(buf, offset)
  let len = bytes.length()

  // 1 0 obj
  let stm = @pdf.Object::Stream(
    @pdf.Dictionary([("/Length", @pdf.Integer(len))]),
    bytes,
  )
  // 2 0 obj - Use define_pages helper
  let pages = define_pages(pages=[@pdf.Indirect(4)])

  // 3 0 obj - Use define_catalog helper
  let catalog = define_catalog(pages=@pdf.Indirect(2), outlines=Null)

  // 4 0 obj - Use define_page and helper functions for resources
  let times_italic_font = @pdf.Dictionary([
    ("/Type", @pdf.Name(b"/Font")),
    ("/Subtype", @pdf.Name(b"/Type1")),
    ("/BaseFont", @pdf.Name(b"/Times-Italic")),
  ])
  let image_bytes = @fs.read_file_to_bytes("resources/images/ocaml.jpg")
  // 5 0 obj 
  //2187x601
  let image = define_jpeg_image(
    image=image_bytes,
    width=2187,
    height=601,
    bpc=8,
    icc=6,
  )
  let icc_bytes = @fs.read_file_to_bytes("resources/typst.icc")
  // 6 0 obj 
  let icc = define_icc(icc=icc_bytes)
  let font_f0 = define_font_item(name=b"/F0", font=times_italic_font)
  let font_resources = define_fonts(fonts=[font_f0])
  let xobjects = define_xobject(xobjs=[(b"/Im0", @pdf.Indirect(5))])
  let page = define_page(contents=@pdf.Indirect(1), parent=@pdf.Indirect(2), resources=[
    font_resources, xobjects,
  ])
  let pdf = make_pdf(@pdf.Indirect(3), [stm, pages, catalog, page, image, icc])
  let offset = @fmt.write(pdf, buf, 0)
  let bytes = bytes_of_memory(buf, offset)
  @fs.write_bytes_to_file("./output/ocaml.pdf", bytes)
  t.writeln(bytes)
  t.snapshot(filename="ocaml.pdf.bytes")
}
