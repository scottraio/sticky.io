#
# Invoke all models we need, expose mongoose

GLOBAL.mongoose = require 'mongoose'

mongoose.connect("mongodb://#{settings.db.server}/#{settings.db.name}")
mongoose.set('debug', true) if app.env is 'development'

require('./user.coffee')
require('./note.coffee')
require('./tag.coffee')
require('./notebook.coffee')
require('./domain.coffee')

app.models			= mongoose.models
module.exports  = mongoose

#mongoose.connection.on 'open', () ->
	# Map/reduce tags into the tag collection
	#app.models.Tag.create_index()


