should  	= require 'should'
Browser		= require 'zombie'
request 	= require 'request'
mock 		= require './helpers/mocks'
provided 	= require './helpers/provided'
Note 		= app.models.Note
User 		= app.models.User

describe 'Tags', () ->

	describe 'restful JSON API', () ->

		beforeEach (done) ->
			provided.we_have_a_note @, done

		it 'should return valid JSON for INDEX', (done) ->
			request.get "http://test%40pine.io:pinerocks@localhost:8000/tags.json", (err, res, body) ->
				#should.not.exist err
				#res.should.be.json
				res.statusCode.should.eql 200
				#body.should.exist

				_body = JSON.parse(body)
				_body.should.be.an.instanceof Array
				done()


		afterEach (done) ->
			app.models.Note.remove {}, (err) -> 
				app.models.User.remove {}, done

	
