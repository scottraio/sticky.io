trebuchet 	= require('trebuchet')('d7fc51d8-e67a-49db-b232-80a5a2fcd84f')

exports.notify_on_error = () ->
	self = @
	process.on 'uncaughtException', (err) ->
		self.send_email_to_admins(err)

exports.send_email_to_admins = (err) ->
	trebuchet.fling
		params:
			from: 'notify@sticky.io'
			to: 'scottraio@gmail.com'
			subject: 'Welcome to Sticky!'
		html: 'app/emails/error.html'
		text: 'app/emails/error.txt'
		data:
			error: err
	, (err, response) ->
		# win
	