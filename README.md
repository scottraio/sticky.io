pine.io
=======

A simple, fast, general purpose, realtime, RESTful database-as-a-service.
A HTML 5 Application platform-as-a-service

Install
-------

	 $ curl -L get.pine.io | bash -s stable

	 or

	 $ gem install pine

Setup
-----

	$ npm -g install nodemon
	$ npm -g install coffee-script
	$ npm -g install mocha

	$ npm install

Run it!
-------

	$ make server


Testing
-------

	$ make test

Todo
----

1. Setup facebook/twitter account (investigate competitors)
2. Website - Embrace HTML5? App Hosting? 
3. Thinking the UI should be more like the prev. Workory UI
4. Restful callbacks after records are saved or updated
5. Get support through Stack Overflow, IRC, Github, Email

Product
-------

1. Define MVP
	a. Deployment
		1. Pine CLI
			a. Service similar to Heroku
			b. `pine create APP_NAME`
				1. Register application with pine service
				2. Download and unpack core .tgz files
				3. Understand current directory e.g. `pine create .`
				4. Allocate subdomain
				5. Append git remote origin
			c. `pine deploy`
				1. Requires user to be in application ROOT
				2. TODO: Figure out remote git deployments
				3. Pine service needs to accept git repository and store files (Amazon S3?)
		2. Support Apps:
			a. Deploying apps
			b. Production mode
			c. Subdomain(landing page for undeployed apps)
			d. Admin UI
		3. Security!
		4. Ability to scaffold an applications (load with backbone, bootstrap, HTML5 boilerplate, etc.)
	b. Database
		1. Needs to resemble mongoDB as much as possible
		2. 100% JSON / RESt
		3. All tests need to pass
	c. Authentication - 
2. Push product on friends/collegues
3. Asses feedback, make changes, introduce to hackernews with premise of 'there are many services like this but this is what we feel works best'

