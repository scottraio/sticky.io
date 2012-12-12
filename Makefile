test:
	NODE_ENV=test NODE_PATH=`pwd`/lib coffee ./test/index.coffee 

development:
	NODE_ENV=development NODE_PATH=`pwd`/lib nodemon ./app.coffee

staging:
	coffee -c app.coffee; NODE_ENV=staging NODE_PATH=`pwd`/lib forever start ./app.js

production:
	coffee -c app.coffee; NODE_ENV=production NODE_PATH=`pwd`/lib forever start ./app.js

deploy:
	./script/deploy-cluster	

.PHONY: test server forever
