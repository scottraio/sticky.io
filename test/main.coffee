GLOBAL.mongoose = require('mongoose')
GLOBAL.app = {}

mongoose.connect('mongodb://localhost/pine-io-test')
mongoose.set('debug', true)

require('../models/manifest')

app.models 		= mongoose.models
module.exports 	= app