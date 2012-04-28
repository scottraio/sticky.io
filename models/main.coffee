#
# Invoke all models we need, expose mongoose
#

GLOBAL.mongoose = require('mongoose')

mongoose.connect('mongodb://localhost/pine-io-development')
mongoose.set('debug', true)

require('./manifest')

app.models		= mongoose.models
module.exports  = mongoose