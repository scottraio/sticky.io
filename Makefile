test:
	NODE_ENV=test NODE_PATH=`pwd`/lib mocha ./test/index.coffee --timeout 10000 --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

development:
	NODE_ENV=development NODE_PATH=`pwd`/lib nodemon ./app.coffee

staging:
	coffee -c app.coffee; NODE_ENV=staging NODE_PATH=`pwd`/lib forever start ./app.js

production:
	coffee -c app.coffee; NODE_ENV=production NODE_PATH=`pwd`/lib forever start ./app.js
	

.PHONY: test server forever
