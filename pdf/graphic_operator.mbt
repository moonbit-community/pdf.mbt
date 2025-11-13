///|
pub impl @fmt.Format for GraphicOperator with write(
  value : GraphicOperator,
  buffer : @fmt.Memory,
  start : Int,
) -> Int {
  try {
    match value {
      Op_w(w) => @fmt.format_write(" {} w", [w], buffer, start)
      Op_J(j) => @fmt.format_write(" {} J", [j], buffer, start)
      Op_j(j) => @fmt.format_write(" {} j", [j], buffer, start)
      Op_M(m) => @fmt.format_write(" {} M", [m], buffer, start)
      Op_cm(t) =>
        @fmt.format_write(
          " {} {} {} {} {} {} cm",
          [t.a, t.b, t.c, t.d, t.e, t.f],
          buffer,
          start,
        )
      Op_BT => @fmt.format_write(" BT", [], buffer, start)
      Op_ET => @fmt.format_write(" ET", [], buffer, start)
      Op_Tf(k, s) => @fmt.format_write(" {} {} Tf", [k, s], buffer, start)
      Op_Tj(s) => @fmt.format_write(" ({}) Tj", [s], buffer, start)
      Op_d(fl, y) => {
        let mut offset = start
        for f in fl {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" {} d", [y], buffer, offset)
        offset - start
      }
      Op_ri(s) => @fmt.format_write(" {} ri", [s], buffer, start)
      Op_i(i) => @fmt.format_write(" {} i", [i], buffer, start)
      Op_gs(s) => @fmt.format_write(" {} gs", [s], buffer, start)
      Op_q => @fmt.format_write(" q", [], buffer, start)
      Op_Q => @fmt.format_write(" Q", [], buffer, start)
      Op_m(a, b) => @fmt.format_write(" {} {} m", [a, b], buffer, start)
      Op_l(a, b) => @fmt.format_write(" {} {} l", [a, b], buffer, start)
      Op_c(a, b, c, d, e, k) =>
        @fmt.format_write(
          " {} {} {} {} {} {} c",
          [a, b, c, d, e, k],
          buffer,
          start,
        )
      Op_v(a, b, c, d) =>
        @fmt.format_write(" {} {} {} {} v", [a, b, c, d], buffer, start)
      Op_y(a, b, c, d) =>
        @fmt.format_write(" {} {} {} {} y", [a, b, c, d], buffer, start)
      Op_h => @fmt.format_write(" h", [], buffer, start)
      Op_re(a, b, c, d) =>
        @fmt.format_write(" {} {} {} {} re", [a, b, c, d], buffer, start)
      Op_S => @fmt.format_write(" S", [], buffer, start)
      Op_s => @fmt.format_write(" s", [], buffer, start)
      Op_f => @fmt.format_write(" f", [], buffer, start)
      Op_F => @fmt.format_write(" F", [], buffer, start)
      Op_f_star => @fmt.format_write(" f*", [], buffer, start)
      Op_B => @fmt.format_write(" B", [], buffer, start)
      Op_B_star => @fmt.format_write(" B*", [], buffer, start)
      Op_b => @fmt.format_write(" b", [], buffer, start)
      Op_b_star => @fmt.format_write(" b*", [], buffer, start)
      Op_n => @fmt.format_write(" n", [], buffer, start)
      Op_W => @fmt.format_write(" W", [], buffer, start)
      Op_W_star => @fmt.format_write(" W*", [], buffer, start)
      Op_Tc(c) => @fmt.format_write(" {} Tc", [c], buffer, start)
      Op_Tw(w) => @fmt.format_write(" {} Tw", [w], buffer, start)
      Op_Tz(z) => @fmt.format_write(" {} Tz", [z], buffer, start)
      Op_TL(l) => @fmt.format_write(" {} TL", [l], buffer, start)
      Op_Tr(i) => @fmt.format_write(" {} Tr", [i], buffer, start)
      Op_Ts(r) => @fmt.format_write(" {} Ts", [r], buffer, start)
      Op_Td(k, k_) => @fmt.format_write(" {} {} Td", [k, k_], buffer, start)
      Op_TD(k, k_) => @fmt.format_write(" {} {} TD", [k, k_], buffer, start)
      Op_Tm(t) =>
        @fmt.format_write(
          " {} {} {} {} {} {} Tm",
          [t.a, t.b, t.c, t.d, t.e, t.f],
          buffer,
          start,
        )
      Op_T_star => @fmt.format_write(" T*", [], buffer, start)
      Op_TJ(obj) => @fmt.format_write(" {} TJ", [obj], buffer, start)
      Op_single_quote(s) => @fmt.format_write(" ({})'", [s], buffer, start)
      Op_double_quote(k, k_, s) =>
        @fmt.format_write(" {} {} ({}) \"", [k, k_, s], buffer, start)
      Op_d0(k, k_) => @fmt.format_write(" {} {} d0", [k, k_], buffer, start)
      Op_d1(a, b, c, d, e, k) =>
        @fmt.format_write(
          " {} {} {} {} {} {} d1",
          [a, b, c, d, e, k],
          buffer,
          start,
        )
      Op_CS(s) => @fmt.format_write(" {} CS", [s], buffer, start)
      Op_cs(s) => @fmt.format_write(" {} cs", [s], buffer, start)
      Op_SC(fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" SC", [], buffer, offset)
        offset - start
      }
      Op_SCN(fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" SCN", [], buffer, offset)
        offset - start
      }
      Op_scn(fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" scn", [], buffer, offset)
        offset - start
      }
      Op_scnName(s, fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" {} scn", [s], buffer, offset)
        offset - start
      }
      Op_SCNName(s, fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" {} SCN", [s], buffer, offset)
        offset - start
      }
      Op_G(k) => @fmt.format_write(" {} G", [k], buffer, start)
      Op_g(k) => @fmt.format_write(" {} g", [k], buffer, start)
      Op_RG(r, g, b) =>
        @fmt.format_write(" {} {} {} Rg", [r, g, b], buffer, start)
      Op_rg(r, g, b) =>
        @fmt.format_write(" {} {} {} rg", [r, g, b], buffer, start)
      Op_K(c, m, y, k) =>
        @fmt.format_write(" {} {} {} {} K", [c, m, y, k], buffer, start)
      Op_k(c, m, y, k) =>
        @fmt.format_write(" {} {} {} {} k", [c, m, y, k], buffer, start)
      Op_sh(s) => @fmt.format_write(" {} sh", [s], buffer, start)
      InlineImage(dict, data) =>
        @fmt.format_write(" BI {} ID {} EI", [dict, data], buffer, start)
      Op_Do(s) => @fmt.format_write(" {} Do", [s], buffer, start)
      Op_MP(s) => @fmt.format_write(" {} MP", [s], buffer, start)
      Op_DP(s, o) => @fmt.format_write(" {} {} DP", [s, o], buffer, start)
      Op_BMC(s) => @fmt.format_write(" {} BMC", [s], buffer, start)
      Op_BDC(s, obj) => @fmt.format_write(" {} {} BDC", [s, obj], buffer, start)
      Op_EMC => @fmt.format_write(" EMC", [], buffer, start)
      Op_BX => @fmt.format_write(" Bx", [], buffer, start)
      Op_Unknown(_) => 0
      Op_Comment(s) => @fmt.format_write(" % {}\n", [s], buffer, start)
      OP_EX => @fmt.format_write(" EX", [], buffer, start)
      Op_sc(fs) => {
        let mut offset = start
        for f in fs {
          offset += @fmt.format_write(" {}", [f], buffer, offset)
        }
        offset += @fmt.format_write(" sc", [], buffer, offset)
        offset - start
      }
    }
  } catch {
    _ => panic()
  }
}

///|
pub impl @fmt.Format for GraphicOperator with count(value : GraphicOperator) -> Int {
  match value {
    // " {} w" = 1 + count(w) + 2 = count(w) + 3
    Op_w(w) => @fmt.count(w) + 3
    // " {} J" = 1 + count(j) + 2 = count(j) + 3  
    Op_J(j) => @fmt.count(j) + 3
    // " {} j" = 1 + count(j) + 2 = count(j) + 3
    Op_j(j) => @fmt.count(j) + 3
    // " {} M" = 1 + count(m) + 2 = count(m) + 3
    Op_M(m) => @fmt.count(m) + 3
    // " {} {} {} {} {} {} cm" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 1 + count(e) + 1 + count(f) + 3
    Op_cm(t) =>
      1 +
      @fmt.count(t.a) +
      1 +
      @fmt.count(t.b) +
      1 +
      @fmt.count(t.c) +
      1 +
      @fmt.count(t.d) +
      1 +
      @fmt.count(t.e) +
      1 +
      @fmt.count(t.f) +
      3
    // " BT" = 3
    Op_BT => 3
    // " ET" = 3  
    Op_ET => 3
    // " {} {} Tf" = 1 + count(k) + 1 + count(s) + 3
    Op_Tf(k, s) => 1 + @fmt.count(k) + 1 + @fmt.count(s) + 3
    // " ({}) Tj" = 2 + count(s) + 4
    Op_Tj(s) => 2 + @fmt.count(s) + 4
    // " {} ... {} d" = sum of (" {}" for each f) + " {} d"
    Op_d(fl, y) =>
      fl.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) +
      1 +
      @fmt.count(y) +
      2
    // " {} ri" = 1 + count(s) + 3
    Op_ri(s) => 1 + @fmt.count(s) + 3
    // " {} i" = 1 + count(i) + 2
    Op_i(i) => 1 + @fmt.count(i) + 2
    // " {} gs" = 1 + count(s) + 3
    Op_gs(s) => 1 + @fmt.count(s) + 3
    // " q" = 2
    Op_q => 2
    // " Q" = 2
    Op_Q => 2
    // " {} {} m" = 1 + count(a) + 1 + count(b) + 2
    Op_m(a, b) => 1 + @fmt.count(a) + 1 + @fmt.count(b) + 2
    // " {} {} l" = 1 + count(a) + 1 + count(b) + 2
    Op_l(a, b) => 1 + @fmt.count(a) + 1 + @fmt.count(b) + 2
    // " {} {} {} {} {} {} c" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 1 + count(e) + 1 + count(k) + 2
    Op_c(a, b, c, d, e, k) =>
      1 +
      @fmt.count(a) +
      1 +
      @fmt.count(b) +
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(d) +
      1 +
      @fmt.count(e) +
      1 +
      @fmt.count(k) +
      2
    // " {} {} {} {} v" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 2
    Op_v(a, b, c, d) =>
      1 +
      @fmt.count(a) +
      1 +
      @fmt.count(b) +
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(d) +
      2
    // " {} {} {} {} y" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 2
    Op_y(a, b, c, d) =>
      1 +
      @fmt.count(a) +
      1 +
      @fmt.count(b) +
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(d) +
      2
    // " h" = 2
    Op_h => 2
    // " {} {} {} {} re" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 3
    Op_re(a, b, c, d) =>
      1 +
      @fmt.count(a) +
      1 +
      @fmt.count(b) +
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(d) +
      3
    // " S" = 2
    Op_S => 2
    // " s" = 2
    Op_s => 2
    // " f" = 2
    Op_f => 2
    // " F" = 2
    Op_F => 2
    // " f*" = 3
    Op_f_star => 3
    // " B" = 2
    Op_B => 2
    // " B*" = 3
    Op_B_star => 3
    // " b" = 2
    Op_b => 2
    // " b*" = 3
    Op_b_star => 3
    // " n" = 2
    Op_n => 2
    // " W" = 2
    Op_W => 2
    // " W*" = 3
    Op_W_star => 3
    // " {} Tc" = 1 + count(c) + 3
    Op_Tc(c) => 1 + @fmt.count(c) + 3
    // " {} Tw" = 1 + count(w) + 3
    Op_Tw(w) => 1 + @fmt.count(w) + 3
    // " {} Tz" = 1 + count(z) + 3
    Op_Tz(z) => 1 + @fmt.count(z) + 3
    // " {} TL" = 1 + count(l) + 3
    Op_TL(l) => 1 + @fmt.count(l) + 3
    // " {} Tr" = 1 + count(i) + 3
    Op_Tr(i) => 1 + @fmt.count(i) + 3
    // " {} Ts" = 1 + count(r) + 3
    Op_Ts(r) => 1 + @fmt.count(r) + 3
    // " {} {} Td" = 1 + count(k) + 1 + count(k_) + 3
    Op_Td(k, k_) => 1 + @fmt.count(k) + 1 + @fmt.count(k_) + 3
    // " {} {} TD" = 1 + count(k) + 1 + count(k_) + 3
    Op_TD(k, k_) => 1 + @fmt.count(k) + 1 + @fmt.count(k_) + 3
    // " {} {} {} {} {} {} Tm" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 1 + count(e) + 1 + count(f) + 3
    Op_Tm(t) =>
      1 +
      @fmt.count(t.a) +
      1 +
      @fmt.count(t.b) +
      1 +
      @fmt.count(t.c) +
      1 +
      @fmt.count(t.d) +
      1 +
      @fmt.count(t.e) +
      1 +
      @fmt.count(t.f) +
      3
    // " T*" = 3
    Op_T_star => 3
    // " " + count(obj) + " TJ" = 1 + count(obj) + 3
    Op_TJ(obj) => 1 + @fmt.count(obj) + 3
    // " {}'" = 1 + count(s) + 1
    Op_single_quote(s) => 1 + @fmt.count(s) + 1 + 2
    // " {} {} {} \"" = 1 + count(k) + 1 + count(k_) + 1 + count(s) + 2
    Op_double_quote(k, k_, s) =>
      1 + @fmt.count(k) + 1 + @fmt.count(k_) + 1 + @fmt.count(s) + 2
    // " {} {} d0" = 1 + count(k) + 1 + count(k_) + 3
    Op_d0(k, k_) => 1 + @fmt.count(k) + 1 + @fmt.count(k_) + 3
    // " {} {} {} {} {} {} d1" = 1 + count(a) + 1 + count(b) + 1 + count(c) + 1 + count(d) + 1 + count(e) + 1 + count(k) + 3
    Op_d1(a, b, c, d, e, k) =>
      1 +
      @fmt.count(a) +
      1 +
      @fmt.count(b) +
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(d) +
      1 +
      @fmt.count(e) +
      1 +
      @fmt.count(k) +
      3
    // " {} CS" = 1 + count(s) + 3
    Op_CS(s) => 1 + @fmt.count(s) + 3
    // " {} cs" = 1 + count(s) + 3
    Op_cs(s) => 1 + @fmt.count(s) + 3
    // sum of (" {}" for each f) + " SC"
    Op_SC(fs) => fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) + 3
    // sum of (" {}" for each f) + " SCN"
    Op_SCN(fs) => fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) + 4
    // sum of (" {}" for each f) + " scn"
    Op_scn(fs) => fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) + 4
    // sum of (" {}" for each f) + " {} scn"
    Op_scnName(s, fs) =>
      fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) +
      1 +
      @fmt.count(s) +
      4
    // sum of (" {}" for each f) + " {} SCN"
    Op_SCNName(s, fs) =>
      fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) +
      1 +
      @fmt.count(s) +
      4
    // " {} G" = 1 + count(k) + 2
    Op_G(k) => 1 + @fmt.count(k) + 2
    // " {} g" = 1 + count(k) + 2
    Op_g(k) => 1 + @fmt.count(k) + 2
    // " {} {} {} Rg" = 1 + count(r) + 1 + count(g) + 1 + count(b) + 3
    Op_RG(r, g, b) =>
      1 + @fmt.count(r) + 1 + @fmt.count(g) + 1 + @fmt.count(b) + 3
    // " {} {} {} rg" = 1 + count(r) + 1 + count(g) + 1 + count(b) + 3
    Op_rg(r, g, b) =>
      1 + @fmt.count(r) + 1 + @fmt.count(g) + 1 + @fmt.count(b) + 3
    // " {} {} {} {} K" = 1 + count(c) + 1 + count(m) + 1 + count(y) + 1 + count(k) + 2
    Op_K(c, m, y, k) =>
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(m) +
      1 +
      @fmt.count(y) +
      1 +
      @fmt.count(k) +
      2
    // " {} {} {} {} k" = 1 + count(c) + 1 + count(m) + 1 + count(y) + 1 + count(k) + 2
    Op_k(c, m, y, k) =>
      1 +
      @fmt.count(c) +
      1 +
      @fmt.count(m) +
      1 +
      @fmt.count(y) +
      1 +
      @fmt.count(k) +
      2
    // " {} sh" = 1 + count(s) + 3
    Op_sh(s) => 1 + @fmt.count(s) + 3
    // " BI {} ID {} EI" = 4 + count(dict) + 4 + count(data) + 3
    InlineImage(dict, data) => 4 + @fmt.count(dict) + 4 + @fmt.count(data) + 3
    // " {} Do" = 1 + count(s) + 3
    Op_Do(s) => 1 + @fmt.count(s) + 3
    // " {} MP" = 1 + count(s) + 3
    Op_MP(s) => 1 + @fmt.count(s) + 3
    // " {} " + count(o) + " DP" = 1 + count(s) + 1 + count(o) + 3
    Op_DP(s, o) => 1 + @fmt.count(s) + 1 + @fmt.count(o) + 3
    // " {} BMC" = 1 + count(s) + 4
    Op_BMC(s) => 1 + @fmt.count(s) + 4
    // " {} " + count(obj) + " BDC" = 1 + count(s) + 1 + count(obj) + 4
    Op_BDC(s, obj) => 1 + @fmt.count(s) + 1 + @fmt.count(obj) + 4
    // " EMC" = 4
    Op_EMC => 4
    // " Bx" = 3
    Op_BX => 3
    // returns 0
    Op_Unknown(_) => 0
    // " % {}\n" = 3 + count(s) + 1
    Op_Comment(s) => 3 + @fmt.count(s) + 1
    // " EX" = 3
    OP_EX => 3
    // sum of (" {}" for each f) + " sc"
    Op_sc(fs) => fs.fold(init=0, fn(acc, f) { acc + 1 + @fmt.count(f) }) + 3
  }
}
