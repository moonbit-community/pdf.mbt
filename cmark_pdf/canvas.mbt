///|
/// Canvas constructor - creates a new empty canvas
pub fn Canvas::new() -> Canvas {
  Canvas([])
}

///|
/// Convert Canvas to Content for PDF generation
pub fn Canvas::to_content(self : Canvas) -> ContentStream {
  ContentStream(self.0)
}

///|
/// Get the underlying array of graphic operators
pub fn Canvas::to_array(self : Canvas) -> Array[@pdf.GraphicOperator] {
  self.0
}

///|
/// Set font and font size
/// 
/// Equivalent to PDF operator: `Tf`
/// Sets the text font and size for subsequent text operations
pub fn Canvas::set_font(self : Canvas, font : Bytes, size : Double) -> Unit {
  self.0.push(@pdf.Op_Tf(font, size))
}

///|
/// Show text string
/// 
/// Equivalent to PDF operator: `Tj`
/// Displays text at the current text position
pub fn Canvas::show_text(self : Canvas, text : Bytes) -> Unit {
  self.0.push(@pdf.Op_Tj(text))
}

///|
/// Set leading (line spacing)
/// 
/// Equivalent to PDF operator: `TL`
/// Sets the distance between lines of text
pub fn Canvas::set_leading(self : Canvas, leading : Double) -> Unit {
  self.0.push(@pdf.Op_TL(leading))
}

///|
/// Move to start of next line
/// 
/// Equivalent to PDF operator: `T*`
/// Moves the text position to the beginning of the next line
pub fn Canvas::next_line(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_T_star)
}

///|
/// Move to next line and show text
/// 
/// Equivalent to PDF operator: `'` (single quote)
/// Combines moving to next line and showing text in one operation
pub fn Canvas::show_text_next_line(self : Canvas, text : Bytes) -> Unit {
  self.0.push(@pdf.Op_single_quote(text))
}

///|
/// Begin text object
/// 
/// Equivalent to PDF operator: `BT`
/// Starts a new text object for text operations
pub fn Canvas::begin_text(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_BT)
}

///|
/// End text object
/// 
/// Equivalent to PDF operator: `ET`
/// Ends the current text object and resets text state
pub fn Canvas::end_text(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_ET)
}

///|
/// Move text position
/// 
/// Equivalent to PDF operator: `Td`
/// Moves to start of next line, offset by (x, y) from current line start
pub fn Canvas::move_text(self : Canvas, x : Double, y : Double) -> Unit {
  self.0.push(@pdf.Op_Td(x, y))
}

///|
/// Move text position and set leading
/// 
/// Equivalent to PDF operator: `TD`
/// Moves to start of next line and sets leading to -y
pub fn Canvas::move_text_set_leading(
  self : Canvas,
  x : Double,
  y : Double,
) -> Unit {
  self.0.push(@pdf.Op_TD(x, y))
}

///|
/// Set character spacing
/// 
/// Equivalent to PDF operator: `Tc`
/// Sets the spacing between individual characters
pub fn Canvas::set_char_spacing(self : Canvas, spacing : Double) -> Unit {
  self.0.push(@pdf.Op_Tc(spacing))
}

///|
/// Set word spacing
/// 
/// Equivalent to PDF operator: `Tw`
/// Sets the spacing between words
pub fn Canvas::set_word_spacing(self : Canvas, spacing : Double) -> Unit {
  self.0.push(@pdf.Op_Tw(spacing))
}

///|
/// Set horizontal text scaling
/// 
/// Equivalent to PDF operator: `Tz`
/// Sets the horizontal scaling factor for text
pub fn Canvas::set_horizontal_scaling(self : Canvas, scale : Double) -> Unit {
  self.0.push(@pdf.Op_Tz(scale))
}

///|
/// Set text rendering mode
/// 
/// Equivalent to PDF operator: `Tr`
/// Sets how text should be rendered (fill, stroke, etc.)
pub fn Canvas::set_text_rendering_mode(self : Canvas, mode : Int) -> Unit {
  self.0.push(@pdf.Op_Tr(mode))
}

///|
/// Set text rise
/// 
/// Equivalent to PDF operator: `Ts`
/// Sets the text rise for superscript/subscript effects
pub fn Canvas::set_text_rise(self : Canvas, rise : Double) -> Unit {
  self.0.push(@pdf.Op_Ts(rise))
}

///|
/// Save graphics state
/// 
/// Equivalent to PDF operator: `q`
/// Saves the current graphics state to the stack
pub fn Canvas::save_state(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_q)
}

///|
/// Restore graphics state
/// 
/// Equivalent to PDF operator: `Q`
/// Restores the graphics state from the stack
pub fn Canvas::restore_state(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_Q)
}

///|
/// Set line width
/// 
/// Equivalent to PDF operator: `w`
/// Sets the width of lines for stroking operations
pub fn Canvas::set_line_width(self : Canvas, width : Double) -> Unit {
  self.0.push(@pdf.Op_w(width))
}

///|
/// Set RGB stroking color
/// 
/// Equivalent to PDF operator: `RG`
/// Sets the RGB color for stroking operations
pub fn Canvas::set_rgb_stroke_color(
  self : Canvas,
  r : Double,
  g : Double,
  b : Double,
) -> Unit {
  self.0.push(@pdf.Op_RG(r, g, b))
}

///|
/// Set RGB fill color
/// 
/// Equivalent to PDF operator: `rg`
/// Sets the RGB color for fill operations
pub fn Canvas::set_rgb_fill_color(
  self : Canvas,
  r : Double,
  g : Double,
  b : Double,
) -> Unit {
  self.0.push(@pdf.Op_rg(r, g, b))
}

///|
/// Set gray level for stroking
/// 
/// Equivalent to PDF operator: `G`
/// Sets the gray level (0-1) for stroking operations
pub fn Canvas::set_gray_stroke(self : Canvas, gray : Double) -> Unit {
  self.0.push(@pdf.Op_G(gray))
}

///|
/// Set gray level for filling
/// 
/// Equivalent to PDF operator: `g`
/// Sets the gray level (0-1) for fill operations
pub fn Canvas::set_gray_fill(self : Canvas, gray : Double) -> Unit {
  self.0.push(@pdf.Op_g(gray))
}

///|
/// Move to point (begin new subpath)
/// 
/// Equivalent to PDF operator: `m`
/// Begins a new subpath by moving to the specified point
pub fn Canvas::move_to(self : Canvas, x : Double, y : Double) -> Unit {
  self.0.push(@pdf.Op_m(x, y))
}

///|
/// Line to point
/// 
/// Equivalent to PDF operator: `l`
/// Appends a straight line segment to the current path
pub fn Canvas::line_to(self : Canvas, x : Double, y : Double) -> Unit {
  self.0.push(@pdf.Op_l(x, y))
}

///|
/// Add rectangle to path
/// 
/// Equivalent to PDF operator: `re`
/// Appends a rectangle to the current path
pub fn Canvas::rectangle(
  self : Canvas,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  self.0.push(@pdf.Op_re(x, y, width, height))
}

///|
/// Close path
/// 
/// Equivalent to PDF operator: `h`
/// Closes the current subpath by appending a straight line from current point to starting point
pub fn Canvas::close_path(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_h)
}

///|
/// Stroke path
/// 
/// Equivalent to PDF operator: `S`
/// Strokes the current path
pub fn Canvas::stroke(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_S)
}

///|
/// Fill path (non-zero winding rule)
/// 
/// Equivalent to PDF operator: `f`
/// Fills the current path using non-zero winding rule
pub fn Canvas::fill(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_f)
}

///|
/// Fill and stroke path (non-zero winding rule)
/// 
/// Equivalent to PDF operator: `B`
/// Fills and strokes the current path using non-zero winding rule
pub fn Canvas::fill_and_stroke(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_B)
}

///|
/// End path without filling or stroking
/// 
/// Equivalent to PDF operator: `n`
/// Ends the path object without filling or stroking
pub fn Canvas::end_path(self : Canvas) -> Unit {
  self.0.push(@pdf.Op_n)
}
