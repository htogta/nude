default: run

run: debug
  ./bin/debug/nude

release:
  mkdir -p ./bin/debug
  odin build src -out:./bin/release/nude

debug:
  mkdir -p ./bin/debug
  odin build src -out:./bin/debug/nude -debug

clean:
  rm -rf bin
