# Sticky.io - Collecting thoughts that stick in realtime.
#
# Web Stack:
#  - NodeJS v0.8
#  - Socket.IO v1.0
#  - MongoDB v2.2
#
# Notes:
#  - XMPP Server uses ejabberd (http://www.ejabberd.com)
#  - Analytics ran through Mixpanel (http://www.mixpanel.com)
#  - SMS Gateway uses Twilio API (http://www.twilio.com)
#  - SMTP Gateway uses Postmark (http://www.postmarkapp.com)
#  - Client HTML uses BackboneJS
#  - Mobile HTML version runs Zepto / SideTap
#  - Authentication uses Passport (devise for Node)

os					= require 'os'
fs					= require 'fs'
http 				= require 'http'
express			= require 'express'
config			= require 'yaml-config'
passport 		= require 'passport' 
cons 				= require 'consolidate'
engine			= require 'ejs-locals'
assets 			= require 'sticky-assets'
flash				= require 'connect-flash'
redis  			= require 'redis'


#
# The App
exports.run = (cb) ->
	fs.readFile 'VERSION', 'utf8', (err, version) ->
		 
		GLOBAL.app 					= module.exports = express.createServer()
		GLOBAL.settings 		= config.readConfig('config/app.yaml')
		GLOBAL.redisclient 	= redis.createClient(settings.redis.port, settings.redis.server)
		app.product_name 		= 'Sticky.io'
		app.version 				= version.replace(/^\s+|\s+$/g, '')
		app.env							= process.env.NODE_ENV

		# sticky modules
		stickymq 		= require 'sticky-kue'
		realtime 		= require 'sticky-realtime'
		exceptions 	= require 'sticky-exceptions'

		#
		# Middleware / Expresx
		RedisStore 		= require('connect-redis')(express)
		redisStore 		= new RedisStore({host:settings.redis.server, port: settings.redis.port})
		cookieParser 	= express.cookieParser('sc2ishard')

		app.root_dir = __dirname

		app.configure () ->
			pub_dir = __dirname + '/public'

			#
			# sticky assets
			app.use assets()

			#
			# ejs templates for top level pages
			app.engine('ejs', engine)

			#
			# defaults
			app.set 'views', __dirname + '/app/views'
			app.set 'view engine', 'ejs'
			app.use express.static(pub_dir)
			app.use express.favicon('public/img/favicon.png')
			app.use express.logger('dev')
			app.use express.bodyParser()
			app.use express.methodOverride()
			app.use cookieParser
			app.use express.session({ store: redisStore })

			#
			# passport authentication
			app.use passport.initialize()
			app.use passport.session()

			#
			# Rails style flash messages
			app.use flash()

			#
			# start the router
			app.use app.router

		#
		# Models - Mongoose
		mongoose 		= require('./app/models')
		app.models 	= mongoose.models

		#
		# Controllers / HTTP Routes
		controllers = require('./app/controllers')

		#
		# spool up the kue and subscribe to redis Pub/Sub for all XMPP/SMS bound notes
		stickymq.listen()
		# notify staff during critical errors
		exceptions.notify_on_error() if app.env is 'production'

		#
		# Boot http server
		server = app.listen(settings.port)
		console.log "info: server running at http://#{settings.domain}"

		#
		# Boot Socket IO
		realtime.start(server, cookieParser, redisStore, redisclient)
		console.log "info: socket.io listeners started"

		cb(app)

unless module.parent
	exports.run () ->
		console.log 'info: ready'
