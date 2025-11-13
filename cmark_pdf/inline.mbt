///|
/// 
/// This function flattens markdown inline elements and converts them to PDF inline types.
/// State is reset each time an item is pushed to the result array.
/// Uses closures to capture mutable state instead of explicit parameter passing.
/// 
pub fn Inline::from_cmark(inline : @cmark.Inline) -> Array[Inline] {
  let result = []

  // Mutable state captured by closures
  let mut is_strong = false
  let mut is_emph = false

  // Helper function to push text with current state and reset all states
  // This closure captures the mutable state variables
  let push_with_state_reset = fn(text : String) -> Unit {
    let inline_item = match (is_strong, is_emph) {
      (true, true) => StrongEmphasis_Emphasis(text)
      (true, false) => StrongEmphasis(text)
      (false, true) => Emphasis(text)
      (false, false) => Plain(text)
    }
    result.push(inline_item)
    // Reset all state after pushing
    is_strong = false
    is_emph = false
  }

  // Recursive helper function to process inline elements
  // This closure captures both the mutable state and the push function
  fn process_inline(inline : @cmark.Inline) -> Unit {
    match inline {
      Text({ v: text, .. }) => push_with_state_reset(text)
      Emphasis({ v: ilem, .. }) => {
        // Set emphasis state and traverse into the content
        is_emph = true
        process_inline(ilem.inline)
      }
      StrongEmphasis({ v: ilstem, .. }) => {
        // Set strong emphasis state and traverse into the content
        is_strong = true
        process_inline(ilstem.inline)
      }
      Inlines({ v: inlines, .. }) => {
        let inlines_array = inlines.to_array()
        for nested_inline in inlines_array {
          process_inline(nested_inline)
        }
      }
      // Handle other inline types that might be encountered
      Link({ v: link, .. }) => process_inline(link.text)
      Image({ v: image, .. }) => process_inline(image.text)
      CodeSpan({ v: code_span, .. }) => push_with_state_reset(code_span.code())
      Break(_) => push_with_state_reset(" ")
      RawHtml(_) =>
        // Skip raw HTML content, no state change
        ()
      Autolink({ v: autolink, .. }) => push_with_state_reset(autolink.link.v)
      // Handle extension types
      ExtStrikethrough({ v: strikethrough, .. }) =>
        process_inline(strikethrough.0)
      ExtMathSpan({ v: math_span, .. }) =>
        push_with_state_reset(math_span.tex())
    }
  }

  // Process the main inline element
  process_inline(inline)
  result
}
