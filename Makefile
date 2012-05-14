all:
	coffee -o src/compiled src/coffee

watch:
	coffee -wo src/compiled src/coffee	

server:
	python -m SimpleHTTPServer
