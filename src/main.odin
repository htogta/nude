package main

import "core:os"
import "core:fmt"

TESTFILE :: "test.nude"

main :: proc() {
  // read file into string
  source, ok := os.read_entire_file(TESTFILE, context.allocator)
  if !ok {
    fmt.println("Error: could not open file")
    os.exit(1)
  }
  defer delete(source, context.allocator)
  
  // init lexer
  lexer := Lexer{
    source = cast(string)source,
    pos = 0,
    line = 1
  }

  // print all tha tokens
  for {
    tok := next_token(&lexer)

    if tok.kind == Token_Kind.EOF do break

    if tok.kind == Token_Kind.Error {
      fmt.printfln("Error on line %d: %s", tok.line, tok.text)
      break
    }
    
    fmt.printfln("%d | <%s> \"%s\"", tok.line, tok.kind, tok.text)
  }
}
