app					= require './app'
os					= require 'os'
cluster 		= require 'cluster'

if cluster.isMaster and process.env.NODE_ENV is 'production'
	# Fork workers.
	for cpu in os.cpus()
		cluster.fork()

	cluster.on 'exit', (worker, code, signal) ->
		console.log('worker ' + worker.process.pid + ' died')
		cluster.fork()
else
	app.start()
