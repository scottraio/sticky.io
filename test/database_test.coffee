should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
Database 	= app.models.Database
User 		= app.models.User

describe 'Database', () ->

	describe 'basic crud operations', () ->

		it 'should save without error', (done) ->
			db = new Database(mock.database)
			db.save(done)

		it 'should create a new collection', (done) ->
			db = new Database(mock.database)
			db.save()

			collection = mongoose.connection.collection(db.title)

			collection.findOne {ok:true}, (err, item) ->
				should.not.exist(err)
				should.exist(item)
				item.should.have.property('ok', true)
				done()

		afterEach (done) ->
			Database.remove {}, done

		return

	describe 'restful JSON API', () ->

		beforeEach (done) ->
			@user 			= new User(mock.user)
			@user.email 	= "test@pine.io"
			@user.save(done)

		it 'should return valid JSON for index', (done) ->
			Browser.visit "http://test%40pine.io:pinerocks@localhost:8000/databases.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				done()

		it 'should return valid JSON for show', (done) ->
			db = new Database(mock.database)
			db.save()

			Browser.visit "http://test%40pine.io:pinerocks@localhost:8000/databases/#{db._id}.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				done()

		afterEach (done) ->
			@user.remove()
			done()

		return

