#
# Invoke all models we need, expose mongoose

GLOBAL.mongoose = require 'mongoose'


mongoose.connect('mongodb://localhost/' + settings.dbname)
mongoose.set('debug', true) if app.env is 'development'

require('./user.coffee')
require('./note.coffee')
require('./group.coffee')
require('./tag.coffee')
require('./notebook.coffee')

app.models			= mongoose.models
module.exports  = mongoose

mongoose.connection.on 'open', () ->
	# Map/reduce tags into the tag collection
	#app.models.Tag.create_index()


