#
# Invoke all models we need, expose mongoose
#

GLOBAL.mongoose = require('mongoose')

mongoose.connect('mongodb://localhost/pine-io-development')
mongoose.set('debug', true)

#mongoose.availablePlugins = require('../lib/mongoose-plugins')

require('./user.coffee')
require('./database.coffee')
require('./help.coffee')

app.models = mongoose.models

#mongoose.models.User.count({}, function (err, num) { console.log('users:',num)  })

module.exports = mongoose.models