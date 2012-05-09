should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
Table 		= app.models.Table
Database 	= app.models.Database
User 		= app.models.User

describe 'Table', () ->

	describe 'basic crud operations', () ->

		it 'should save without error', (done) ->
			table = new Table(mock.table)
			table.save(done)

		afterEach (done) ->
			Database.remove {}, done

		return

describe 'Table restful JSON API', () ->

		beforeEach (done) ->
			self 			= @
			@user 			= new User(mock.user)
			@user.email 	= "test@pine.io"
			@user.save (err) ->
				db 			= new Database(mock.database)
				db.user_id 	= self.user._id
				db.save (err) ->
					self.url = "#{db.title}/tables"
					done()

		it 'should return valid JSON for index', (done) ->
			Browser.visit "http://test%40pine.io:pinerocks@localhost:8000/#{@url}.json", {debug: false}, (err, brs, status) ->
				should.not.exist err
				status.should.eql 200
				{headers:brs.response[1]}.should.be.json
				brs.response[1].should.exist
				console.log brs
				done()

		afterEach (done) ->
			@user.remove()
			done()

		return