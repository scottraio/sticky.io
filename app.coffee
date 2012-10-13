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

# XMPP bridge
xmpp 				= require 'sticky-xmpp'

# SocketIO stuff
redis  			= require 'redis'
realtime 		= require 'sticky-realtime'

# Analytics
mixpanel 		= require 'mixpanel'




#
# The App
GLOBAL.app 				= module.exports = express.createServer()
GLOBAL.settings 	= config.readConfig('config/app.yaml')
app.product_name 	= 'Sticky.io'
app.env						= process.env.NODE_ENV

#
# Set the redis client to the GLOBAL namespace
GLOBAL.redisclient 	= redis.createClient(settings.redis.port, settings.redis.server)

#
# Middleware / Expresx
RedisStore 		= require('connect-redis')(express)
redisStore 		= new RedisStore({host:settings.redis.server, port: settings.redis.port})
cookieParser 	= express.cookieParser('sc2ishard')

app.root_dir = __dirname

app.configure () ->
	pub_dir = __dirname + '/public'

	# connect-assets: rails 3.1 asset pipeline for nodejs
	app.use assets buildDir: 'public', src: 'app/assets'

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
# Models - Mongoose
mongoose = require('./app/models')
app.models = mongoose.models

#
# Controllers / HTTP Routes
require('./app/controllers')

#
# Subscribe to Redis Pub/Sub for all XMPP bound notes
xmpp.subscribe()

#
# Boot http server
server = app.listen(settings.port)
console.log "Server running at http://#{settings.domain}"

#
# Boot Socket IO
realtime.start(server, cookieParser, redisStore, redisclient)
console.log "info: socket.io listeners started"

#
# Setup mixpanel analytics
app.mixpanel = mixpanel.init('dc318d85f647b3cc6ff0992c0af24729')
console.log "Mixpanel initiated"