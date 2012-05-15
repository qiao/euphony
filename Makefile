all: $(shell find src/coffee -name "*.coffee" -type f)
	coffee -o src/compiled src/coffee

watch:
	coffee -wo src/compiled src/coffee	

server:
	python -m SimpleHTTPServer

.PHONY: watch server
