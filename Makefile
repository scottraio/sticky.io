test:
	NODE_ENV=test mocha ./test/index.coffee --timeout 10000 --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

.PHONY: test