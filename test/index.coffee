require '../app'
mock = require './mocks'

User 		= app.models.User
Database 	= app.models.Database
Table 		= app.models.Table
Record 		= app.models.Record

User.remove()
Database.remove()
Table.remove()
Record.remove()

require './database_test'
require './user_test'
require './table_test'
require './record_test'


