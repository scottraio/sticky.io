#
# Sticky.io - Collecting thoughts that stick in realtime.
#

fs					= require 'fs'
http 				= require 'http'
express			= require 'express'
cons 				= require 'consolidate'
config			= require 'yaml-config'
handlbars 	= require 'handlebars'
engine			= require 'ejs-locals'
passport 		= require 'passport'
assets 			= require 'connect-assets'
flash				= require 'connect-flash'
xmpp 				= require 'sticky-xmpp'

#
#
# Config
GLOBAL.settings = config.readConfig('config/app.yaml')

#
#
# The App
GLOBAL.app 				= module.exports = express.createServer()
app.product_name 	= 'Sticky.io'
app.env						= process.env.NODE_ENV

#
#
# Middleware / Express
app.root_dir = __dirname

app.configure () ->
	pub_dir = __dirname + '/public'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets(buildDir: 'public', src: 'app/assets')

	# handlebar templates :-)
	app.engine('ejs', engine)

	# Defaults
	app.set 'views', __dirname + '/app/views'
	app.set 'view engine', 'ejs'
	app.use express.static(pub_dir)
	app.use express.favicon('public/img/favicon.png')
	app.use express.logger('dev')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser('sc2ishard')
	app.use express.session({ store: require('mongoose-session') })

	# passport authentication
	app.use passport.initialize()
	app.use passport.session()

	# Rails style flash messages
	app.use flash()

	# start the router
	app.use app.router

#
#
# Mongoose models
mongoose = require('./app/models')
app.models = mongoose.models

#
#
# Controllers
require('./app/controllers')


#
# Boot server
#
xmpp.start()
server = app.listen(settings.port)

console.log "Server running at http://#{settings.domain}"
