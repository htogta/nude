package parser

import "lexer"
import "codegen" // will implement this guy next, should be straightforward

Parser :: struct {
  lexer: ^lexer.Lexer
  cg: ^codegen.Codegen
  current: lexer.Token
}

init_parser :: proc(l: ^lexer.Lexer, c: ^codegen.Codegen) -> Parser {
  p := Parser{lexer = l, cg = c}
  advance(p)
  return p
}

peek :: proc(p: ^Parser) {
  return p.current
}

advance :: proc(p: ^Parser) {
  p.current = next_token(p.lexer)
}

expect :: proc(p: ^Parser, kind: lexer.Token_Kind) -> Token {
  tok := p.current
  if tok.kind != kind {
    // TODO report error
  }
  advance(p)
  return tok
}

parse_program :: proc(p: ^Parser) {
  for p.current.kind != lexer.Token_Kind.EOF {
    switch p.current.kind {
      case lexer.Token_Kind.Let: parse_let_stmt(p)
      case: parse_word(p)
    }
  }
}

parse_let_stmt :: proc(p: ^Parser) {
  expect(p, Token_Kind.Let)
  identifier_token := expect(p, Token_Kind.Word)

  // skip past the arity, if it's present
  if p.current.kind == Token_Kind.Left_Paren {
    for p.current.kind != Token_Kind.Right_Paren do advance(p)
    expect(p, Token_Kind.Right_Paren)
  }

  expect(p, Token_Kind.Left_Bracket)
  // TODO emit let start

  for p.current.kind != Token_Kind.Right_Bracket {
    if p.current.kind == Token_Kind.Return {
      codegen.emit(p.cg, "%return")
    } else if p.current.kind == Token_Kind.Recurse {
      // TODO emit recurse
    } else {
      parse_word()
    }
  }

  expect(p, Token_Kind.Right_Bracket)
  // TODO emit let end
}

parse_loop :: proc(p: ^Parser) {
  expect(p, Token_Kind.Loop)
  expect(p, Token_Kind.Left_Bracket) // start of block

  // TODO emit loop start

  for p.current.kind != Token_Kind.Right_Bracket {
    if p.current.kind == Token_Kind.Continue {
      // TODO emit continue
    } else if p.current.kind == Token_Kind.Break {
      // TODO emit break
    } else {
      parse_word()
    }
  }

  expect(p, Token_Kind.Right_Bracket)
  // TODO emit loop end
}

parse_quote :: proc(p: ^Parser) {
  expect(p, Token_Kind.Left_Bracket)

  // TODO emit start of quote, then
  for p.current.kind != Token_Kind.Right_Bracket do parse_word(p)
  expect(p, Token_Kind.Right_Bracket)
  // then, emit end of quote (TODO)
}

parse_word :: proc(p: ^Parser) {
  tok := peek(p)

  switch tok.kind {
    case lexer.Token_Kind.Byte: codegen.emit(p.cg, "%byte")
    case lexer.Token_Kind.Short: codegen.emit(p.cg, "%short")
    case lexer.Token_Kind.Addr: codegen.emit(p.cg, "%addr")
    case lexer.Token_Kind.Int: codegen.emit(p.cg, "%int")
    case lexer.Token_Kind.Int2byte: codegen.emit(p.cg, "%int2byte")
    case lexer.Token_Kind.Int2short: codegen.emit(p.cg, "%int2short")
    case lexer.Token_Kind.Int2addr: codegen.emit(p.cg, "%int2addr")
    case lexer.Token_Kind.Byte2int: codegen.emit(p.cg, "%byte2int")
    case lexer.Token_Kind.Short2int: codegen.emit(p.cg, "%short2int")
    case lexer.Token_Kind.Addr2int: codegen.emit(p.cg, "%addr2int")
    case lexer.Token_Kind.Zap: codegen.emit(p.cg, "%zap")
    case lexer.Token_Kind.Dup: codegen.emit(p.cg, "%dup")
    case lexer.Token_Kind.Swap: codegen.emit(p.cg, "%swap")
    case lexer.Token_Kind.Stash: codegen.emit(p.cg, "%stash")
    case lexer.Token_Kind.Restore: codegen.emit(p.cg, "%restore")
    case lexer.Token_Kind.Plus: codegen.emit(p.cg, "%plus")
    case lexer.Token_Kind.Ampersand: codegen.emit(p.cg, "%ampersand")
    case lexer.Token_Kind.Caret: codegen.emit(p.cg, "%caret")
    case lexer.Token_Kind.Neg: codegen.emit(p.cg, "%neg")
    case lexer.Token_Kind.Left_Shift: codegen.emit(p.cg, "%lsh")
    case lexer.Token_Kind.Right_Shift: codegen.emit(p.cg, "%rsh")
    case lexer.Token_Kind.Equals: codegen.emit(p.cg, "%equals")
    case lexer.Token_Kind.Greater: codegen.emit(p.cg, "%greater")
    case lexer.Token_Kind.Less: codegen.emit(p.cg, "%less")
    case lexer.Token_Kind.Greater_Equal: codegen.emit(p.cg, "%greater_equal")
    case lexer.Token_Kind.Less_Equal: codegen.emit(p.cg, "%less_equal")
    case lexer.Token_Kind.Not_Equal: codegen.emit(p.cg, "%not_equal")
    case lexer.Token_Kind.And: codegen.emit(p.cg, "%bool_and")
    case lexer.Token_Kind.Or: codegen.emit(p.cg, "%bool_or")
    case lexer.Token_Kind.Not: codegen.emit(p.cg, "%bool_not")
    case lexer.Token_Kind.Byte_Load: codegen.emit(p.cg, "%byte_at")
    case lexer.Token_Kind.Short_Load: codegen.emit(p.cg, "%short_at")
    case lexer.Token_Kind.Addr_Load: codegen.emit(p.cg, "%addr_at")
    case lexer.Token_Kind.Int_Load: codegen.emit(p.cg, "%int_at")
    case lexer.Token_Kind.Byte_Store: codegen.emit(p.cg, "%byte_bang")
    case lexer.Token_Kind.Short_Store: codegen.emit(p.cg, "%short_bang")
    case lexer.Token_Kind.Addr_Store: codegen.emit(p.cg, "%addr_bang")
    case lexer.Token_Kind.Int_Store: codegen.emit(p.cg, "%int_bang")
    case lexer.Token_Kind.Byte_Fetch: codegen.emit(p.cg, "%byte_caret")
    case lexer.Token_Kind.Short_Fetch: codegen.emit(p.cg, "%short_caret")
    case lexer.Token_Kind.Addr_Fetch: codegen.emit(p.cg, "%addr_caret")
    case lexer.Token_Kind.Int_Fetch: codegen.emit(p.cg, "%int_caret")
    case lexer.Token_Kind.Left_Bracket: parse_quote(p)
    case lexer.Token_Kind.Apply: codegen.emit(p.cg, "%apply")
    case lexer.Token_Kind.Choose: codegen.emit(p.cg, "%choose")
    case lexer.Token_Kind.MK2_Inline: // TODO emit mk2 inline
    case lexer.Token_Kind.True: codegen.emit(p.cg, "%true")
    case lexer.Token_Kind.False: codegen.emit(p.cg, "%false")
    case lexer.Token_Kind.Loop: parse_loop(p)
    case lexer.Token_Kind.Number: // TODO emit number
    case lexer.Token_Kind.Hex: // TODO emit hex
    case: // TODO throw error, if we get here something unexpected happened
  }
}
