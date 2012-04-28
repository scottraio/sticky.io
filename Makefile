test:
	mocha ./test/unit/*.coffee --reporter landing --compilers coffee:coffee-script

.PHONY: test