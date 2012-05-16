app = require '../app'
mock = require './mocks'

app.models.Collection.remove {}
app.models.Database.remove {}
app.models.User.remove {}

require './database_test'
require './user_test'
require './collection_test'
require './record_test'


