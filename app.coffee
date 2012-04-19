#
# Init
#

express		= require 'express'
http 		= require 'http'
hulk		= require 'hulk-hogan' # templating
mongoose 	= require 'mongoose'
schema 		= require './db/schema'
routes		= require './routes'

#
# Mongoose models
#

mongoose.connect('mongodb://localhost/pine-io-development')
mongoose.model 'User', 		schema.users(mongoose.Schema)
mongoose.model 'Database', 	schema.databases(mongoose.Schema)
mongoose.model 'Field', 	schema.fields(mongoose.Schema)
mongoose.model 'Record', 	schema.records(mongoose.Schema)

#
# Middleware
#

app = module.exports = express()

app.configure () ->
	app.set('views', __dirname + '/views')
	app.set('view options', layout:false)
  	app.set('view engine', 'hulk')
  	app.register('.hulk', hulk)
	app.use(express.favicon())
	app.use(express.logger('dev'))
	app.use(express.static(__dirname + '/public'))
	app.use(express.bodyParser())
	app.use(express.methodOverride())
	app.use(app.router)

app.configure 'development', () ->
	app.use(express.errorHandler())

#
# Routes
#

app.get('/', routes.index)

#
# Boot server
#

app.listen(8000)

console.log 'Server running at http://127.0.0.1:8000/'