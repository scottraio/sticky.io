test:
	NODE_ENV=test mocha ./test/index.coffee --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

.PHONY: test