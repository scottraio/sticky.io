TwilioClient 	= require('twilio').Client
Twiml 				= require('twilio').Twiml

client = new TwilioClient('ACeba74e18bc45af33034acfe7a589d8dd', '5df203053a11df3926be5a2eb8116f6e', 'sticky.io')

exports.poll = () ->
	setInterval(()->
		client.getSmsList {}, ((data) ->
			#
			# loop through each sms message
			sids = []
			for message in data.sms_messages
				sids.push message.sid

			app.models.Note.where('_sms_id').in(sids).run (err, notes) ->  			
				if notes.length > 0
					#
					# find all the notes with sms_ids (messages that were added earlier from sms)
					sms_ids = []
					for note in notes
						sms_ids.push note._sms_id[0]
					#
					# iterate over all sms messages
					for message in data.sms_messages
						exports.save_sms_message(message) if sms_ids.indexOf(message.sid) is -1
				else
					for message in data.sms_messages
						exports.save_sms_message(message)
		), 
		(() ->
			console.log 'error'
		)
	, 25000)

exports.save_sms_message = (message) ->
	app.models.User.findOne {phone_number:message.from}, (err, user) ->
		if user
			note = new app.models.Note()
			note.set 'message', 		message.body
			note.set '_user', 			user._id
			note.set 'created_at', 	new Date()
			note.set '_sms_id', 		message.sid

			#
			# parse tags/links/groups into arrays
			note.parse()

			#
			# save note
			note.save (err) ->
				if err
					console.log err
