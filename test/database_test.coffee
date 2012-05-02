should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
Database 	= app.models.Database

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

	describe 'restful JSON API', () ->

		beforeEach (done) ->
			user 		= new app.models.User(mock.user)
			user.email 	= 'test@pine.io'
			user.save(done)

		it 'should return valid JSON', (done) ->
			Browser.visit "http://test%40pine.io:c0llegato@localhost:8000/databases.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				done()

		afterEach (done) ->
			app.models.User.remove 		{}
			app.models.Database.remove 	{}
			done()

