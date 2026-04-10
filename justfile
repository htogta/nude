default: test

test: build
  ./bin/nude test.nude

build:
  mkdir -p bin
  cc src/main.c src/lexer.c -o bin/nude

clean:
  rm -rf bin
