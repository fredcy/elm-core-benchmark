TOOLS = $(HOME)/Documents/elm/elm-tools

build: elm.js

elm.js: Main.elm FastList.elm vendor/benchmark
	elm make Main.elm --output=elm.js --yes

test: Test.elm
	elm make Test.elm --output=test.html

clean:
	rm elm.js

vendor/elm-benchmark:
	git clone git@github.com:fredcy/elm-benchmark.git vendor/elm-benchmark

vendor/benchmark: vendor/elm-benchmark
	python $(TOOLS)/localize.py $< $@

usefork:
	mv elm-stuff/packages/elm-lang/core/4.0.3 elm-stuff/packages/elm-lang/core/bak
	ln -s $(HOME)q/Documents/elm/elm-lang-core elm-stuff/packages/elm-lang/core/4.0.3

PAGES = docs

github-pages:
	mkdir -p $(PAGES)
	cp bench.html $(PAGES)/index.html
	cp chart.css chart.js elm.js $(PAGES)
