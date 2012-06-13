xmpp = require 'simple-xmpp'

exports.welcome = () ->
	green = '\u001b[32m'
	reset = '\u001b[0m';
	console.log green + " _______  _______  ___   _______  ___   _  __   __ " + reset
	console.log green + "|       ||       ||   | |       ||   | | ||  | |  |" + reset
	console.log green + "|  _____||_     _||   | |       ||   |_| ||  |_|  |" + reset
	console.log green + "| |_____   |   |  |   | |       ||      _||       |" + reset
	console.log green + "|_____  |  |   |  |   | |      _||     |_ |_     _|" + reset
	console.log green + " _____| |  |   |  |   | |     |_ |    _  |  |   |" + reset
	console.log green + "|_______|  |___|  |___| |_______||___| |_|  |___|" + reset


exports.start = () ->
	return true if app.config.env is 'test'

	#
	# Load up Derby (XMPP bot)
	#
	xmpp.on 'online', ->
		status = new xmpp.Element('presence').c('show').t('chat').up().c('status').t('http://sticky.io')	
		xmpp.conn.send(status)

		# Welcome the developer with the Pine.io ASCII art
		exports.welcome()

	xmpp.on 'error', (e) ->
		console.log e

	#
	# Used when someone sends pine a message through XMPP
	#
	xmpp.on 'chat', (from, message) ->
		app.models.User.findOne {email:from}, (err, user) ->
			unless user is undefined or user is null
				exports.save_message(user, message)
			else
				#
				# Welcome the new user and present a signup link
				xmpp.send(from, "Welcome to #{app.product_name} friend! Before we begin, please follow this link: http://#{app.config.domain}/auth/google")
	#
	# Used when someone adds the pine bot as a buddy through XMPP
	#
	xmpp.on 'stanza', (stanza) ->
		# stanza's are how XMPP communicates with S2S or S2C
		# this stanza auto-accepts new friend requests
		if stanza.is('presence')
			#
			# send 'subscribed' to new friend requests
			if stanza.attrs.type is 'subscribe'
				validate = new xmpp.Element('presence', {type: 'subscribed', to: stanza.attrs.from})
				xmpp.conn.send(validate)
			#
			# send 'unsubscribed' to new friend removals
			if stanza.attrs.type is 'unsubscribe'
				validate = new xmpp.Element('presence', {type: 'unsubscribed', to: stanza.attrs.from})
				xmpp.conn.send(validate)

	#
	# Connect the pine bot to the XMPP universe
	#
	xmpp.connect
		# set the jabber ID to either derby or derby-dev
		jid: app.config.xmpp.jid
		password: app.config.xmpp.password
		host: app.config.xmpp.host
		port: 5222

#
#
# Stick it!

exports.save_message = (user, message) ->
	note = new app.models.Note()
	#
	# setup the note
	note.set 'message', 	message
	note.set 'created_at', 	new Date()
	note.set '_user', 		user._id
	
	#
	# parse tags into note.tags
	note.parse_tags()
	#
	# parse links into note.links
	note.parse_links()

	#
	# save the note
	note.save (err) ->
		console.log "Message saved" if app.env is "development"


