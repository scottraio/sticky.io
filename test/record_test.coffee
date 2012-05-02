should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
Record 		= app.models.Record
Table 		= app.models.Table
Database 	= app.models.Database
User 		= app.models.User

describe 'Record', () ->

	describe 'basic crud operations', () ->

		it 'should save without error', (done) ->
			db 	= new Database(mock.database)
			db.save (err) ->
				record 				= new Record(mock.record)
				record.database_id 	= db._id
				
				record.set_collection(db.title)
				record.save(done)

		afterEach (done) ->
			#Record.remove {}, done
			done()

		return

describe 'restful JSON API', () ->

		beforeEach (done) ->
			self 			= @
			@user 			= new User(mock.user)
			@user.email 	= "test@pine.io"
			@user.save (err) ->
				db 			= new Database(mock.database)
				db.user_id 	= self.user._id
				db.save (err) ->
					table 				= new Table(mock.table)
					table.user_id 		= self.user_id
					table.database_id 	= db._id
					table.save (err) ->
						self.url = "#{db.title}/#{table.title}/records"
						done()

		it 'should return valid JSON for index', (done) ->
			Browser.visit "http://test%40pine.io:pinerocks@localhost:8000/#{@url}.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				brs.response[1].should.exist
				done()

		afterEach (done) ->
			@user.remove()
			done()

		return