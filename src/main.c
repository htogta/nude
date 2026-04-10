#include <stdio.h>
#include <stdlib.h>
#include <assert.h> // just for debug
#include "lexer.h"


// TODO real error handling!
static char* read_file(const char* path) {
  FILE* file = fopen(path, "rb");

  fseek(file, 0L, SEEK_END);
  size_t file_size = ftell(file);
  rewind(file);

  char* buffer = malloc(file_size + 1);
  size_t bytes_read = fread(buffer, sizeof(char), file_size, file);
  buffer[bytes_read] = '\0';

  fclose(file);
  return buffer;
}

int main(int argc, const char* argv[]) {
  // TODO for now we'll just open the first arg that gets passed
  assert(argc == 2); // just for debug
  char* source = read_file(argv[1]);
  Lexer l = init_lexer(source);

  int line = -1;
  for (;;) {
    Token token = next_token(&l);
    if (token.line != line) {
      printf("%4d ", token.line);
      line = token.line;
    } else {
      printf("   | ");
    }
    printf("%s '%.*s'\n", token_to_str(token.kind), token.length, token.start); 

    if (token.kind == TOKEN_EOF) break;
  }

  free(source);
  return 0;
}
