test:
	NODE_ENV=test NODE_PATH=`pwd`/lib mocha ./test/index.coffee --timeout 10000 --reporter list --compilers coffee:coffee-script --globals app,mongoose,params

development:
	NODE_ENV=development NODE_PATH=`pwd`/lib nodemon ./server.coffee

staging:
	coffee -c server.coffee; NODE_ENV=staging NODE_PATH=`pwd`/lib forever start ./server.js

production:
	coffee -c server.coffee; NODE_ENV=production NODE_PATH=`pwd`/lib forever start ./server.js

deploy:
	./script/deploy-cluster	

.PHONY: test server forever
