should  	= require 'should'
app 		= require '../main'
Database 	= app.models.Database

describe 'Database', () ->
	describe 'basic crud operations', () ->

		it 'should save without error', (done) ->
			db 			= new Database()
			db.title 	= 'Todos'
			db.user_id 	= 1
			db.save(done)

		it 'should update without error', (done) ->
			db 			= new Database()
			db.title 	= 'Todos'
			db.user_id 	= 1
			db.save(done)
