welcome = () ->
	green = '\u001b[32m'
	reset = '\u001b[0m';
	console.log green + " _______  ___   __    _  _______" + reset
	console.log green + "|       ||   | |  |  | ||       |" + reset
	console.log green + "|    _  ||   | |   |_| ||    ___|" + reset
	console.log green + "|   |_| ||   | |       ||   |___ " + reset
	console.log green + "|    ___||   | |  _    ||    ___|" + reset
	console.log green + "|   |    |   | | | |   ||   |___ " + reset
	console.log green + "|___|    |___| |_|  |__||_______|" + reset

#	 _______  _______  ___   _______  ___   _  __   __ 
#	|       ||       ||   | |       ||   | | ||  | |  |
#	|  _____||_     _||   | |       ||   |_| ||  |_|  |
#	| |_____   |   |  |   | |       ||      _||       |
#	|_____  |  |   |  |   | |      _||     |_ |_     _|
#	 _____| |  |   |  |   | |     |_ |    _  |  |   |  
#	|_______|  |___|  |___| |_______||___| |_|  |___|

#
# Init
#

fs			= require 'fs'
http 		= require 'http'
express		= require 'express'
cons 		= require 'consolidate'
handlbars 	= require 'handlebars'
passport 	= require 'passport'
assets 		= require 'connect-assets'
flash		= require 'connect-flash'
xmpp 		= require 'simple-xmpp'

#
# The App
#

GLOBAL.app 			= module.exports = express.createServer()
app.product_name 	= 'Pine.io'

#
# Middleware
#

app.root_dir = __dirname

app.configure () ->
	pub_dir = __dirname + '/public'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets(build: false, buildDir: 'public')

	# handlebar templates :-)
	app.engine('html', cons.handlebars)

	# Defaults
	app.set 'views', __dirname + '/app/views'
	app.set 'view engine', 'html'
	app.use express.static(pub_dir)
	app.use express.favicon()
	app.use express.logger('dev')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser('sc2ishard')
	app.use express.session({ store: require('./lib/mongoose_session') })

	# passport authentication
	app.use passport.initialize()
	app.use passport.session()

	# Rails style flash messages
	app.use flash()

	# start the router
	app.use app.router


#
# Environments
#

app.configure 'production', () ->
	app.config =
		env 			: 'production'
		dbname 			: 'pine-io-production'
		domain 			: 'pine.io'
		xmpp 			:
			jid			: 'notes@pine.io'
			host		: 'pine.io'
			password	: 'p!new00dF1d3rby'
		google_oauth 	:
			client_id 	: '293797332075-en00tcg0jhnuktrnkk89j95j6g1dipqi.apps.googleusercontent.com'
			secret		: 'R3o_wrzOo6B7DDmpzcU2rto4'
			redirect 	: '/auth/google/callback'
		

app.configure 'development', () ->
	app.use(express.errorHandler())
	app.config =
		env 			: 'development'
		dbname 			: 'pine-io-development'
		domain 			: 'dev.pine.io:8000'
		xmpp 			:
			jid			: 'notes-dev@pine.io'
			host		: 'pine.io'
			password	: 'p!new00dF1d3rby'
		google_oauth 	:
			client_id 	: '293797332075.apps.googleusercontent.com'
			secret		: 'rtqXf-Ows1RgGn5V5oUg5Qa7'
			redirect 	: '/auth/google/callback'

app.configure 'test', () ->
	app.use(express.errorHandler())
	app.config =
		env 			: 'test'
		dbname 			: 'pine-io-test'
		domain 			: 'dev.pine.io:8000'
		xmpp 			:
			jid			: 'notes-dev@pine.io'
			host		: 'pine.io'
			password	: 'p!new00dF1d3rby'
		google_oauth 	:
			client_id 	: '293797332075.apps.googleusercontent.com'
			secret		: 'rtqXf-Ows1RgGn5V5oUg5Qa7'
			redirect 	: '/auth/google/callback'
	

#
# Mongoose models
#

mongoose = require('./app/models')
app.models = mongoose.models

#
# Routes, Controllers, & Views
#


fs.readFile './app/views/header.html', (err, data) -> handlbars.registerPartial 'header', data.toString()
fs.readFile './app/views/footer.html', (err, data) -> handlbars.registerPartial 'footer', data.toString()
fs.readFile './app/views/nav.html', (err, data) -> handlbars.registerPartial 'nav', data.toString()
fs.readFile './app/views/notes.html', (err, data) -> handlbars.registerPartial 'notes', data.toString()

handlbars.registerPartial 'vendor_js', js('vendor')
handlbars.registerPartial 'app_js', js('app')
handlbars.registerPartial 'stylesheets', css('app')


require('./app/controllers')

#
# Load up Derby (XMPP bot)
#
xmpp.on 'online', ->
	# Welcome the developer with the Pine.io ASCII art
	welcome()

xmpp.on 'error', (e) ->
	console.log e

#
# Used when someone sends pine a message through XMPP
#
xmpp.on 'chat', (from, message) ->
	app.models.User.findOne {email:from}, (err, user) ->
		if user
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
# Boot server
#
app.listen(8000)

console.log 'Server running at http://127.0.0.1:8000/'
