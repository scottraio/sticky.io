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

GLOBAL.app 		= module.exports = express.createServer()

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
	app.dbname = 'pine-io-production'

app.configure 'development', () ->
	app.use(express.errorHandler())
	app.dbname = 'pine-io-development'

app.configure 'test', () ->
	app.use(express.errorHandler())
	app.dbname = 'pine-io-test'
	

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
	welcome()

xmpp.on 'error', (e) ->
	console.log e

xmpp.on 'chat', (from, message) ->
	app.models.User.findOne {email:from}, (err, user) ->
		if user
			note = new app.models.Note()
		
			note.set 'message', 	message
			note.set 'created_at', 	new Date()
			note.set '_user', 		user._id
			
			note.save (err) ->
				console.log "Message saved" if app.dbname is "pine-io-development"
		else
			xmpp.send(from, "Welcome to Pine.io friend! Before we begin, please follow this link: http://pine.io/signup/")

xmpp.on 'stanza', (stanza) ->
	
	if stanza.is('presence') 
		if stanza.attrs.type is 'subscribe'
			validate = new xmpp.Element('presence', {type: 'subscribed', to: stanza.attrs.from})
			xmpp.conn.send(validate)

		if stanza.attrs.type is 'unsubscribe'
			validate = new xmpp.Element('presence', {type: 'unsubscribed', to: stanza.attrs.from})
			xmpp.conn.send(validate)

xmpp.connect
	jid: "derby@pine.io"
	password: "dif3ndere"
	host: "pine.io"
	port: 5222

#
# Boot server
#
app.listen(8000)

console.log 'Server running at http://127.0.0.1:8000/'

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
