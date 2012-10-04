#
# Sticky.io - Collecting thoughts that stick in realtime.
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
sms 				= require 'sticky-sms'
realtime 		= require 'sticky-realtime'
mixpanel 		= require 'mixpanel'

#
# The App
GLOBAL.app 				= module.exports = express.createServer()
GLOBAL.settings 	= config.readConfig('config/app.yaml')
app.product_name 	= 'Sticky.io'
app.env						= process.env.NODE_ENV

#
# Middleware / Express
RedisStore = require('connect-redis')(express)
redisStore = new RedisStore( { host:settings.redis.server, port: 6379})
cookieParser = express.cookieParser('sc2ishard')

app.root_dir = __dirname

app.configure () ->
	pub_dir = __dirname + '/public'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets(buildDir: 'public', src: 'app/assets', buildFilenamer: (filename, code) -> filename)

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
	app.use cookieParser
	app.use express.session({ store: redisStore })

	# passport authentication
	app.use passport.initialize()
	app.use passport.session()

	# Rails style flash messages
	app.use flash()

	# start the router
	app.use app.router

#
# Mongoose models
mongoose = require('./app/models')
app.models = mongoose.models

#
#
# Controllers
require('./app/controllers')

#
# Start XMPP Bot
xmpp.start()

#
# Start SMS Polling
#if app.env is 'development'
#	sms.poll()


#
# Boot server
server = app.listen(settings.port)
console.log "Server running at http://#{settings.domain}"

#
# Socket IO
realtime.start(server, cookieParser, redisStore)
console.log "Realtime initiated"

#
# Setup mixpanel analytics
app.mixpanel = mixpanel.init('dc318d85f647b3cc6ff0992c0af24729')
console.log "Mixpanel initiated"