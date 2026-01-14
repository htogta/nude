package main

import "core:os"
import "core:fmt"
import "lexer"

main :: proc() {
  if len(os.args) != 2 {
    fmt.println("Error: invalid args, expected a path to a .nude file")
    os.exit(1)
  }
  file_path := os.args[1]

  // read file into string
  source, ok := os.read_entire_file(file_path, context.allocator)
  if !ok {
    fmt.println("Error: could not open file")
    os.exit(1)
  }
  defer delete(source, context.allocator)
  
  // init lexer
  l := lexer.Lexer{
    source = cast(string)source,
    pos = 0,
    line = 1
  }

  // print all tha tokens
  for {
    tok := lexer.next_token(&l)

    if tok.kind == lexer.Token_Kind.EOF do break

    if tok.kind == lexer.Token_Kind.Error {
      fmt.printfln("Error on line %d: %s", tok.line, tok.text)
      break
    }
    
    fmt.printfln("%d | <%s> \"%s\"", tok.line, tok.kind, tok.text)
  }
}
