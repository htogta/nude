default: test

test: debug
  ./bin/debug/nude test.nude

release:
  mkdir -p ./bin/debug
  odin build src -out:./bin/release/nude

debug:
  mkdir -p ./bin/debug
  odin build src -out:./bin/debug/nude -debug

clean:
  rm -rf bin
