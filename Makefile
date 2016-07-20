TOOLS = $(HOME)/Documents/elm/elm-tools

build: elm.js

elm.js: Main.elm
	elm make Main.elm --output=elm.js

vendor/elm-benchmark:
	git clone git@github.com:fredcy/elm-benchmark.git vendor/elm-benchmark

vendor/benchmark: vendor/elm-benchmark
	python $(TOOLS)/localize.py $< $@

