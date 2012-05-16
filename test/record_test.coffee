should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
http 		= require './http_helper'
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
			Database.remove {}, done

	describe 'restful JSON API', () ->

		beforeEach (done) ->
			self 			= @
			@user 			= new User(mock.user)
			@user.save (err) ->
				self.db 			= new Database(mock.database)
				self.db.user_id 	= self.user._id
				self.db.save (err) ->
					self.collection 				= new Collection(mock.collection)
					self.collection.user_id 		= self.user_id
					self.collection.database_id 	= self.db._id
					self.collection.save (err) ->
						self.url = "/#{self.db.title}/#{self.collection.title}/records"
						done()

		it 'should return valid JSON for index', (done) ->
			#http.get "test@pine.io", "pinerocks", "#{@url}.json", (err, res) ->
			#	console.log err
			#	console.log res
			#	done()
			

		afterEach (done) ->
			User.remove {}, (err) ->
				Database.remove {}, (err) ->
					Collection.remove {}, done
		