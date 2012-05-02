#
# Invoke all models we need, expose mongoose
#

GLOBAL.mongoose = require 'mongoose'

mongoose.connect('mongodb://localhost/' + app.dbname)
mongoose.set('debug', true) if app.dbname is 'pine-io-development'

require('./manifest')

app.models		= mongoose.models
module.exports  = mongoose