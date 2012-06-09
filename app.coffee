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
xmpp 		= require './lib/xmpp'
io 			= require './lib/realtime'

#
# The App
#

GLOBAL.app 			= module.exports = express.createServer()
app.product_name 	= 'Sticky.io'

#
# Middleware
#

app.root_dir = __dirname

app.configure () ->
	pub_dir = __dirname + '/public'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets(build: true, buildDir: 'public')

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
		domain 			: 'sticky.io'
		xmpp 			:
			jid			: 'notes@sticky.io'
			host		: 'sticky.io'
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
		domain 			: 'dev.sticky.io:8000'
		xmpp 			:
			jid			: 'notes-dev@sticky.io'
			host		: 'sticky.io'
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
			jid			: 'notes-dev@sticky.io'
			host		: 'sticky.io'
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
fs.readFile './app/views/bookmarks.html', (err, data) -> handlbars.registerPartial 'bookmarks', data.toString()

handlbars.registerPartial 'vendor_js', js('vendor')
handlbars.registerPartial 'app_js', js('app')
handlbars.registerPartial 'stylesheets', css('app')


require('./app/controllers')
 

#
# Boot server
#
xmpp.start()
server = app.listen(8000)
io.start(server)

console.log 'Server running at http://127.0.0.1:8000/'
