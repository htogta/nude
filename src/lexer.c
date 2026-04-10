#include <stdbool.h>
#include <string.h>
#include "lexer.h"

Lexer init_lexer(const char* source) {
  Lexer l;
  l.source = source;
  l.pos = 0;
  l.line = 1;
  return l;
}

static char peek(Lexer* l) {
  return l->source[l->pos];
}

static char advance(Lexer* l) {
  char ch = peek(l);
  if (ch == '\0') return '\0';
  l->pos++;
  if (ch =='\n') l->line++;
  return ch;
}

static bool is_whitespace(char ch) {
  return (ch == ' ') || (ch == '\t') || (ch == '\n') || (ch == '\r');
}

static void skip_whitespace(Lexer* l) {
  while (is_whitespace(peek(l))) advance(l);
}

static bool is_decimal(const char* lexeme, int length) {
  if (length == 1 && (lexeme[0] < '0' || lexeme[0] > '9')) return false;

  int i; // this should work?
  if (lexeme[0] == '-') { // is negative
    i = 1;
  } else {
    i = 0;
  }
  for (; i < length; i++) {
    char ch = lexeme[i];
    if (ch < '0' || ch > '9') return false;
  }

  // TODO bounds checking? if has no negative sign, can be between
  // 0 and 4294967295, if it *has* a negative sign, can be between
  // -2147483648 and 2147483647.

  return true;
}

// hex literals are a # followed by between 1 and 8 hex digits
static bool is_hex(const char* lexeme, int length) {
  if (length < 2) return false;
  if (lexeme[0] != '#') return false;
  for (int i = 1; i < length; i++) {
    char ch = lexeme[i];
    if ((ch < 'a' || ch > 'f') && (ch < 'A' || ch > 'F') && (ch < '0' || ch > '9')) return false;
  }

  if ((length - 1) > 8) {
    // TODO error token, too many digits!
  }

  return true;
}

static TokenKind check_keyword(const char* lexeme, int length) {
  // otherwise, it's some kind of keyword
  switch (lexeme[0]) {
    case '&':
      if (length == 1) return TOKEN_AMPERSAND;
      break;

    case '(':
      if (length == 1) return TOKEN_LPAREN;
      break;

    case ')':
      if (length == 1) return TOKEN_RPAREN;
      break;

    case '+':
      if (length == 1) return TOKEN_PLUS;
      break;

    case '-':
      if (length == 2 && memcmp(lexeme, "->", 2) == 0) return TOKEN_ARROW;
      break;

    case '/':
      if (length == 2 && memcmp(lexeme, "/=", 2) == 0) return TOKEN_NOT_EQUALS;
      break;

    case '<':
      if (length == 1) return TOKEN_LESS;
      if (length == 2 && memcmp(lexeme, "<<", 2) == 0) return TOKEN_LSH;
      if (length == 2 && memcmp(lexeme, "<=", 2) == 0) return TOKEN_LESS_EQUALS;
      break;

    case '>':
      if (length == 1) return TOKEN_GREATER;
      if (length == 2 && memcmp(lexeme, ">=", 2) == 0) return TOKEN_GREATER_EQUALS;
      if (length == 2 && memcmp(lexeme, ">>", 2) == 0) return TOKEN_RSH;
      break;
  
    case '[':
      if (length == 1) return TOKEN_LBRACKET;
      break;

    case ']':
      if (length == 1) return TOKEN_RBRACKET;
      break;

    case '^':
      if (length == 1) return TOKEN_CARET;
      break;

    case 'a':
      if (length == 4 && memcmp(lexeme, "addr", 4) == 0) return TOKEN_ADDR;
      if (length == 5 && memcmp(lexeme, "addr!", 5) == 0) return TOKEN_ADDR_BANG;
      if (length == 5 && memcmp(lexeme, "addr@", 5) == 0) return TOKEN_ADDR_AT;
      if (length == 5 && memcmp(lexeme, "addr^", 5) == 0) return TOKEN_ADDR_CARET;
      if (length == 3 && memcmp(lexeme, "and", 3) == 0) return TOKEN_AND;
      if (length == 5 && memcmp(lexeme, "apply", 5) == 0) return TOKEN_APPLY;
      break;

    case 'b':
      if (length == 4 && memcmp(lexeme, "bool", 4) == 0) return TOKEN_BOOL;
      if (length == 5 && memcmp(lexeme, "break", 5) == 0) return TOKEN_BREAK;
      if (length == 4 && memcmp(lexeme, "byte", 4) == 0) return TOKEN_BYTE;
      if (length == 5 && memcmp(lexeme, "byte!", 5) == 0) return TOKEN_BYTE_BANG;
      if (length == 5 && memcmp(lexeme, "byte@", 5) == 0) return TOKEN_BYTE_AT;
      if (length == 5 && memcmp(lexeme, "byte^", 5) == 0) return TOKEN_BYTE_CARET;
      break;

    case 'c':
      if (length == 6 && memcmp(lexeme, "choose", 6) == 0) return TOKEN_CHOOSE;
      if (length == 8 && memcmp(lexeme, "continue", 8) == 0) return TOKEN_CONTINUE;
      break;

    case 'd':
      if (length == 3 && memcmp(lexeme, "dup", 3) == 0) return TOKEN_DUP;
      break;

    case 'e':
      if (length == 3 && memcmp(lexeme, "end", 3) == 0) return TOKEN_END;
      break;

    case 'f':
      if (length == 5 && memcmp(lexeme, "false", 5) == 0) return TOKEN_FALSE;
      break;

    case 'i':
      if (length == 3 && memcmp(lexeme, "int", 3) == 0) return TOKEN_INT;
      if (length == 4 && memcmp(lexeme, "int!", 4) == 0) return TOKEN_INT_BANG;
      if (length == 4 && memcmp(lexeme, "int@", 4) == 0) return TOKEN_INT_AT;
      if (length == 4 && memcmp(lexeme, "int^", 4) == 0) return TOKEN_INT_CARET;
      break;

    case 'l':
      if (length == 4 && memcmp(lexeme, "load", 4) == 0) return TOKEN_LOAD;
      if (length == 4 && memcmp(lexeme, "loop", 4) == 0) return TOKEN_LOOP;
      break;

    case 'n':
      if (length == 3 && memcmp(lexeme, "neg", 3) == 0) return TOKEN_NEG;
      if (length == 3 && memcmp(lexeme, "not", 3) == 0) return TOKEN_NOT;
      break;

    case 'o':
      if (length == 2 && memcmp(lexeme, "or", 2) == 0) return TOKEN_OR;
      break;

    case 'r':
      if (length == 7 && memcmp(lexeme, "recurse", 7) == 0) return TOKEN_RECURSE;
      if (length == 7 && memcmp(lexeme, "restore", 7) == 0) return TOKEN_RESTORE;
      break;

    case 's':
      if (length == 4 && memcmp(lexeme, "self", 4) == 0) return TOKEN_SELF;
      if (length == 5 && memcmp(lexeme, "short", 5) == 0) return TOKEN_SHORT;
      if (length == 6 && memcmp(lexeme, "short!", 6) == 0) return TOKEN_SHORT_BANG;
      if (length == 6 && memcmp(lexeme, "short@", 6) == 0) return TOKEN_SHORT_AT;
      if (length == 6 && memcmp(lexeme, "short^", 6) == 0) return TOKEN_SHORT_CARET;
      if (length == 5 && memcmp(lexeme, "stash", 5) == 0) return TOKEN_STASH;
      if (length == 4 && memcmp(lexeme, "swap", 4) == 0) return TOKEN_SWAP;
      break;
    
    case 't':
      if (length == 4 && memcmp(lexeme, "true", 4) == 0) return TOKEN_TRUE;
      if (length == 4 && memcmp(lexeme, "type", 4) == 0) return TOKEN_TYPE;
      break;

    case 'z':
      if (length == 3 && memcmp(lexeme, "zap", 3) == 0) return TOKEN_ZAP;
      break;
  }

  return TOKEN_WORD;
}

static TokenKind get_token_kind(const char* lexeme, int length) {
  if (is_decimal(lexeme, length)) return TOKEN_DECIMAL;
  if (is_hex(lexeme, length)) return TOKEN_HEX;

  // check if it's a word definition
  if (length > 1 && lexeme[length - 1] == ':') {
    // TODO ensure that it's not just ':'?
    // also ensure that it's not redefining a built-in keyword:
    if (check_keyword(lexeme, length - 1) != TOKEN_WORD) {
      // TODO return error token type?
    }
    return TOKEN_WORDDEF;
  }

  return check_keyword(lexeme, length);

}

static Token read_word(Lexer* l) {
  int start_pos = l->pos;
  int start_line = l->line;

  for (;;) {
    char ch = peek(l);
    if ((ch == 0) || is_whitespace(ch)) break;
    advance(l);
  }

  int length = l->pos - start_pos;
  TokenKind kind = get_token_kind(l->source + start_pos, length);

  Token tok;
  tok.kind = kind;
  tok.start = l->source + start_pos;
  tok.length = length;
  tok.line = start_line;
  return tok;
}

static void skip_comment(Lexer* l) {
  advance(l); // skip the ;

  for (;;) {
    char ch = peek(l);
    if (ch == '\0' || ch == '\n') break;
    advance(l);
  }
}

Token next_token(Lexer* l) {
  for (;;) {
    skip_whitespace(l);
    char ch = peek(l);

    if (ch == '\0') {
      Token tok;
      tok.kind = TOKEN_EOF;
      tok.start = ""; // i think this is fine?
      tok.length = 1;
      tok.line = l->line;
      return tok;
    }

    if (ch == ';') {
      skip_comment(l);
      continue;
    }
    
    return read_word(l);
  }
}
