exports.subscribe = (jobs) ->
	jobs.process 'notes:create', (job, done) ->
		# find the user first
		app.models.User.findOne {_id:job.data.user}, (err, user) ->
			unless user is undefined or user is null		
				app.models.Note.create_note user, job.data.message, (err, note) ->

					# if we're saving a message from SMS then we'll associate
					# the note with the sms_id from Twilio
					if job.data._sms_id
						# set the sms id to track its source
						note.set '_sms_id', job.data._sms_id
						note.save (err) ->
							return false if err
							done()
					else
						return false if err
						done()

		
