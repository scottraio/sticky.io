should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
Record 		= app.models.Record
Collection 	= app.models.Collection
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
			@user.email 	= "test-record@pine.io"
			@user.save (err) ->
				self.db 			= new Database(mock.database)
				self.db.user_id 	= self.user._id
				self.db.save (err) ->
					self.collection 				= new Collection(mock.collection)
					self.collection.user_id 		= self.user_id
					self.collection.database_id 	= self.db._id
					self.collection.save (err) ->
						self.url = "#{self.db.title}/#{self.collection.title}/records"
						done()

		it 'should return valid JSON for index', (done) ->
			Browser.visit "http://test-record%40pine.io:pinerocks@localhost:8000/#{@url}.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				brs.response[1].should.exist
				done()

		it 'should save formatted data', (done) ->
			Browser.visit "http://test-record%40pine.io:pinerocks@localhost:8000/#{@url}.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				brs.response[1].should.exist
				done()

		afterEach (done) ->
			User.remove {}
			Database.remove {}
			Collection.remove {}
			done()

		return
		