test:
	NODE_ENV=test mocha ./test/index.coffee --timeout 10000 --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

server: 
	NODE_ENV=development nodemon ./app.coffee

forever: 
	NODE_ENV=production; coffee -c app.coffee; forever start ./app.js

.PHONY: test server forever