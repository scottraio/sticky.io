#
# Init
#

fs			= require 'fs'
http 		= require 'http'
express		= require 'express'
cons 		= require 'consolidate'
handlbars 	= require 'handlebars'
passport 	= require 'passport'
lesscss 	= require 'less-middleware'


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
	pub_dir = __dirname + '/public'

	app.engine('html', cons.handlebars);

	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'html'

	app.use lesscss(src: pub_dir, compress: true)
	app.use express.static(pub_dir)

	app.use express.favicon()
	app.use express.logger('dev')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser('sc2ishard')
	app.use express.session({ secret: 'sc2ishard' })
	app.use passport.initialize()
	app.use passport.session()
	app.use app.router

app.configure 'development', () ->
	app.use(express.errorHandler())

#
# Routes, Controllers, & Views
#

fs.readFile './views/header.html', (err, data) -> handlbars.registerPartial 'header', data.toString()
fs.readFile './views/footer.html', (err, data) -> handlbars.registerPartial 'footer', data.toString()

require('./controllers/main')

#
# Boot server
#

app.listen(8000)

console.log 'Server running at http://127.0.0.1:8000/'