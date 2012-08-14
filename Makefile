test:
	NODE_ENV=test NODE_PATH=`pwd`/lib mocha ./test/index.coffee --timeout 10000 --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

development:
	NODE_ENV=development NODE_PATH=`pwd`/lib nodemon ./app.coffee

staging:
	NODE_ENV=staging NODE_PATH=`pwd`/lib coffee -c app.coffee; forever start ./app.js

production:
	NODE_ENV=production NODE_PATH=`pwd`/lib coffee -c app.coffee; forever start ./app.js

.PHONY: test server forever
