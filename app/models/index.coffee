#
# Invoke all models we need, expose mongoose
#


GLOBAL.mongoose = require 'mongoose'


mongoose.connect('mongodb://localhost/' + app.config.dbname)
mongoose.set('debug', true) if app.config.env is 'development'

require('./manifest')

app.models			= mongoose.models
module.exports  = mongoose

mongoose.connection.on 'open', () ->
	# Map/reduce tags into the tag collection
	#app.models.Tag.create_index()
