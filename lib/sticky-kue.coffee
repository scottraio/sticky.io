kue 			= require 'kue'
redis 		= require 'redis'
sanitize 	= require('validator').sanitize # xss protection

#
# Connection settings
kue.redis.createClient = () -> redis.createClient(settings.redis.port, settings.redis.server)
jobs = kue.createQueue()

exports.listen = () ->
	jobs.process 'notes:create', (job, done) ->
		# find the user first
		app.models.User.findOne {_id:job.data.user}, (err, user) ->
			unless user is undefined or user is null		
				message = sanitize(job.data.message).xss()

				app.models.Note.create_note user, message, (err, note) ->

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

#
# Methods
exports.registerXMPPBot = (email) ->
	payload = {email: email}
	jobs.create('users:register', payload).priority('high').save()

exports.confirmPhoneNumber = (number, token) ->
	payload = {phone_number: number, confirm_code: token}
	jobs.create('users:confirm:phone_number', payload).save()
