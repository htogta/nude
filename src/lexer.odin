package main

// individual token types
Token_Kind :: enum {
  // these three used for effect notation, like ( -- )
  Left_Paren,
  Right_Paren,
  Double_Dash,

  // these are our base type names
  Byte, // single byte value, akin to uint8_t
  Short, // two bytes, uint16_t
  Addr, // three bytes- default address size, akin to uintptr_t
  Int, // four bytes, uint32_t

  // type conversions
  Int2byte, Int2short, Int2addr, Byte2int, Short2int, Addr2int,

  // built-in stack operations
  Zap, Dup, Swap, Stash, Restore,

  // built-in math operations
  Plus, Ampersand, Caret, Neg, Left_Shift, Right_Shift,

  // built-in comparisons
  Equals, Greater, Less, Greater_Equal, Less_Equal, Not_Equal,

  // boolean operations
  And, Or, Not,

  // memory operations
  Byte_Load, Short_Load, Addr_Load, Int_Load, // end in @, read from RAM
  Byte_Store, Short_Store, Addr_Store, Int_Store, // end in !, write to RAM
  Byte_Fetch, Short_Fetch, Addr_Fetch, Int_Fetch, // end in ^, write to flash

  // I/O operations
  Getchar, Putchar,
  
  // these are used for quotations and subroutine definitions
  Left_Bracket, // [
  Right_Bracket, // ]
  Let, // let

  // these are reserved for control flow and such
  Apply, // call subroutine at address
  Return, // return from subroutine
  Recurse, // recursively call subroutine
  Continue, // only allowed in loops
  Break, // only allowed in loops
  Choose, // condition fn
  Loop,

  // inline MK2 assembly
  MK2_Inline,

  Word, // user-defined word

  // these are our literals
  Number, // base10 number, can have a minus sign at the start, long by default
  Hex, // base16 number, starts with # prefix
  True, // boolean literals
  False, 

  Error, // invalid token (like a string that was never closed)
  EOF,
}

Token :: struct {
  kind: Token_Kind,
  text: string, // slice into source
  line: int
}

Lexer :: struct {
  source: string,
  pos: int,
  line: int
}

peek :: proc(l: ^Lexer) -> u8 {
  if l.pos >= len(l.source) do return 0
  return l.source[l.pos]
}

advance :: proc(l: ^Lexer) -> u8 {
  ch := peek(l)
  if ch == 0 do return 0
  l.pos += 1
  if ch == '\n' do l.line += 1
  return ch
}

is_whitespace :: proc(ch: u8) -> bool {
  return ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'
}

skip_whitespace :: proc(l: ^Lexer) {
  for is_whitespace(peek(l)) do advance(l)
}

skip_comment :: proc(l: ^Lexer) {
  // consume the ';'
  advance(l)

  for {
    ch := peek(l)
    if ch == 0 || ch == '\n' do break
    advance(l)
  }
}

// checks if lexeme is decimal number literal
is_number :: proc(s: string) -> bool {
  if s[0] == '-' {
    for ch in s[1:] {
      if ch < '0' || ch > '9' do return false
    }
    return len(s) > 1
  } else {
    for ch in s {
      if ch < '0' || ch > '9' do return false
    } 
    return len(s) > 0
  }
}

is_hex_digit :: proc(ch: rune) -> bool {
  return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')
}

// checks if lexeme is a valid hex literal
is_hex :: proc(s: string) -> bool {
  // check for '#' prefix
  if s[0] != '#' do return false
  
  for ch in s[1:] {
    if !is_hex_digit(ch) do return false
  }
  
  return len(s) > 1
}

get_token_kind :: proc(s: string) -> Token_Kind {
  if is_number(s) do return Token_Kind.Number
  if is_hex(s) do return Token_Kind.Hex

  // otherwise, it's a keyword:
  switch s {
    case "(": return Token_Kind.Left_Paren
    case ")": return Token_Kind.Right_Paren
    case "--": return Token_Kind.Double_Dash
    case "zap": return Token_Kind.Zap
    case "dup": return Token_Kind.Dup
    case "swap": return Token_Kind.Swap
    case "stash": return Token_Kind.Stash
    case "restore": return Token_Kind.Restore
    case "recurse": return Token_Kind.Recurse
    case "break": return Token_Kind.Break
    case "continue": return Token_Kind.Continue
    case "MK2<": return Token_Kind.MK2_Inline
    case "+": return Token_Kind.Plus
    case "&": return Token_Kind.Ampersand
    case "^": return Token_Kind.Caret
    case "neg": return Token_Kind.Neg
    case "<<": return Token_Kind.Left_Shift
    case ">>": return Token_Kind.Right_Shift
    case "=": return Token_Kind.Equals
    case ">": return Token_Kind.Greater
    case "<": return Token_Kind.Less
    case ">=": return Token_Kind.Greater_Equal
    case "<=": return Token_Kind.Less_Equal
    case "/=": return Token_Kind.Not_Equal
    case "and": return Token_Kind.And
    case "not": return Token_Kind.Not
    case "or": return Token_Kind.Or
    case "byte@": return Token_Kind.Byte_Load
    case "short@": return Token_Kind.Short_Load
    case "addr@": return Token_Kind.Addr_Load
    case "int@": return Token_Kind.Int_Load
    case "byte!": return Token_Kind.Byte_Store
    case "short!": return Token_Kind.Short_Store
    case "addr!": return Token_Kind.Addr_Store
    case "int!": return Token_Kind.Int_Store
    case "byte^": return Token_Kind.Byte_Fetch
    case "short^": return Token_Kind.Short_Fetch
    case "addr^": return Token_Kind.Addr_Fetch
    case "int^": return Token_Kind.Int_Fetch
    case "getchar": return Token_Kind.Getchar
    case "putchar": return Token_Kind.Putchar
    case "loop": return Token_Kind.Loop
    case "choose": return Token_Kind.Choose
    case "byte": return Token_Kind.Byte
    case "short": return Token_Kind.Short
    case "addr": return Token_Kind.Addr
    case "int": return Token_Kind.Int
    case "int2byte": return Token_Kind.Int2byte
    case "int2short": return Token_Kind.Int2short
    case "int2addr": return Token_Kind.Int2addr
    case "byte2int": return Token_Kind.Byte2int
    case "short2int": return Token_Kind.Short2int
    case "addr2int": return Token_Kind.Addr2int
    case "[": return Token_Kind.Left_Bracket
    case "]": return Token_Kind.Right_Bracket
    case "apply": return Token_Kind.Apply
    case "return": return Token_Kind.Return
    case "true": return Token_Kind.True
    case "false": return Token_Kind.False
    case: return Token_Kind.Word // default
  }
}

is_word_boundary :: proc(ch: u8) -> bool {
  return ch == 0 || is_whitespace(ch)
}

read_mk2_inline :: proc(l: ^Lexer) -> Token {
  start_line := l.line

  // we just consumed the "MK2<", require a word boundary
  if !is_word_boundary(peek(l)) {
    return Token{
      kind = Token_Kind.Error,
      text = "MK2< must be followed by at least one space",
      line = start_line,
    }
  }

  // consume the whitespace after MK2<
  skip_whitespace(l)

  content_start := l.pos
  for {
    ch := peek(l)
    if ch == 0 {
      return Token{
        kind = Token_Kind.Error,
        text = "Unterminated inline MK2 block (missing >MK2)",
        line = start_line
      }
    }

    // check for ">MK2" at word boundary
    if ch == '>' && 
      l.pos+4 <= len(l.source) && 
      l.source[l.pos:l.pos+4] == ">MK2" &&
      is_word_boundary(l.source[l.pos+4] if l.pos+4 < len(l.source) else 0) 
    {
      content := l.source[content_start:l.pos]

      // consume ">MK2"
      advance(l)
      advance(l)
      advance(l)
      advance(l)

      return Token{
        kind = Token_Kind.MK2_Inline,
        text = content,
        line = start_line
      }
    }

    advance(l)
  }
}

read_word :: proc(l: ^Lexer) -> Token {
  start_pos := l.pos
  start_line := l.line

  for {
    ch := peek(l)
    if ch == 0 || is_whitespace(ch) do break
    advance(l)
  }

  lexeme := l.source[start_pos:l.pos]

  kind := get_token_kind(lexeme)

  return Token{
    kind = kind,
    text = lexeme,
    line = start_line
  }
}

next_token :: proc(l: ^Lexer) -> Token {
  for {
    skip_whitespace(l)
  
    ch := peek(l)
  
    if ch == 0 {
      return Token{
        kind = Token_Kind.EOF,
        text = "",
        line = l.line
      }
    }
  
    if ch == ';' {
      skip_comment(l)
      continue
    }

    // peek word without consuming immediately for mk2_inline
    start_pos := l.pos
    tok := read_word(l)
    if tok.kind == Token_Kind.MK2_Inline do return read_mk2_inline(l)
  
    return tok
  }
}
