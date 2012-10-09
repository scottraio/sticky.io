kue 	= require 'kue'
jobs 	= kue.createQueue()

exports.subscribe = () ->
	#client.subscribe 'sticky:xmpp'
	
	#client.on 'message', (channel, message) ->
	#	payload = JSON.parse(message)
	
	jobs.process 'notes:create', (job, done) ->
		app.models.User.findOne {_id:job.data.user}, (err, user) ->
			unless user is undefined or user is null		
				app.models.Note.create_note user, job.data.message, (err, note) ->
					return false if err
					done()

		
