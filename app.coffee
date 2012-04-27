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

#
# The App
#

GLOBAL.app = module.exports = express.createServer()

#
# Mongoose models
#

require('./models/main')

#
# Middleware
#


app.configure () ->
	pub_dir = __dirname + '/assets'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets(build: true, buildDir: 'public')

	# handlebar templates :-)
	app.engine('html', cons.handlebars);

	# Defaults
	app.set 'views', __dirname + '/views'
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

app.configure 'development', () ->
	app.use(express.errorHandler())

#
# Routes, Controllers, & Views
#


fs.readFile './views/header.html', (err, data) -> handlbars.registerPartial 'header', data.toString()
fs.readFile './views/footer.html', (err, data) -> handlbars.registerPartial 'footer', data.toString()
handlbars.registerPartial 'javascripts', js('vendor')
handlbars.registerPartial 'stylesheets', css('app')


require('./controllers/main')

#
# Boot server
#

app.listen(8000)

console.log 'Server running at http://127.0.0.1:8000/'