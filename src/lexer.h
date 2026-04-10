#ifndef NUDE_LEXER_H
#define NUDE_LEXER_H

typedef enum {
  TOKEN_WORD,
  TOKEN_LBRACKET, TOKEN_RBRACKET, // [ ] (used for quotes and word/type defs)
  TOKEN_TYPE, // "type", used for type declarations
  TOKEN_LOAD, // "load", used to include code from other files at compile time

  // used for word definitions
  TOKEN_WORDDEF, // any word that ends in a colon
  TOKEN_ARROW, // ->
  TOKEN_LPAREN, TOKEN_RPAREN, // used for quotations in type signatures

  // bare minimum type names:
  TOKEN_BOOL, // 8-bit value, 00 is true, ff is false
  TOKEN_BYTE, // 8-bit value
  TOKEN_SHORT, // 16-bit value
  TOKEN_ADDR, // 24-bit value
  TOKEN_INT, // 32-bit value
  // used in stack effect signatures, but can also push the size of each of
  // these types, in bytes, as an int (i.e. "byte" pushes 1, "short" pushes 2, 
  // etc)

  // bare minimum control flow
  TOKEN_LOOP, // simple infinite loop
  TOKEN_BREAK, TOKEN_CONTINUE, // used in loops
  TOKEN_CHOOSE, // simple conditional execution
  TOKEN_RETURN, TOKEN_RECURSE, // used in word definitions
  TOKEN_APPLY, // apply a quotation
  TOKEN_SELF, // push the addr of the current quotation to the stack
  TOKEN_END, // return early from a quotation
  
  // basic stack manipulation words
  TOKEN_ZAP, TOKEN_DUP, TOKEN_SWAP,
  TOKEN_STASH, TOKEN_RESTORE, // for the return stack

  // basic arithmetic/bitwise words
  TOKEN_PLUS, TOKEN_AMPERSAND, TOKEN_CARET, TOKEN_NEG, TOKEN_LSH, TOKEN_RSH,

  // basic comparison/boolean words
  TOKEN_EQUALS, TOKEN_GREATER, TOKEN_LESS, TOKEN_GREATER_EQUALS, 
  TOKEN_LESS_EQUALS, TOKEN_NOT_EQUALS,
  TOKEN_AND, TOKEN_OR, TOKEN_NOT,

  // basic memory manipulation words
  TOKEN_BYTE_AT, TOKEN_SHORT_AT, TOKEN_ADDR_AT, TOKEN_INT_AT, // read from RAM
  TOKEN_BYTE_BANG, TOKEN_SHORT_BANG, 
  TOKEN_ADDR_BANG, TOKEN_INT_BANG, // write to RAM
  TOKEN_BYTE_CARET, TOKEN_SHORT_CARET, 
  TOKEN_ADDR_CARET, TOKEN_INT_CARET, // read from ROM
  
  // literals
  TOKEN_DECIMAL, // base-10 integer literal, can have a negative sign
  TOKEN_HEX, // base-16 integer literal, starts with a #
  TOKEN_TRUE, TOKEN_FALSE, // boolean literals
  TOKEN_STRING, // string literal, like in C (TODO escape sequences?)

  // TODO error token?
  TOKEN_EOF
} TokenKind;

typedef struct {
  TokenKind kind;
  const char* start;
  int length;
  int line;
} Token;

typedef struct {
  const char* source;
  int pos;
  int line;
} Lexer;

Lexer init_lexer(const char* source);
Token next_token(Lexer* l);

#endif // NUDE_LEXER_H
