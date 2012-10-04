should  	= require 'should'
Browser		= require 'zombie'
request 	= require 'request'
mock 			= require './helpers/mocks'
provided 	= require './helpers/provided'
Note 			= app.models.Note
User 			= app.models.User

describe 'Note', () ->

	describe 'restful JSON API', () ->

		beforeEach (done) ->
			provided.we_have_a_note @, done

		it 'should return valid JSON for INDEX', (done) ->
			request.get "http://test%40pine.io:pinerocks@localhost:8000/notes.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist

				_body = JSON.parse(body)
				_body.should.be.an.instanceof Array
				done()

		it 'should return valid JSON for SHOW', (done) ->
			request.get "http://test%40pine.io:pinerocks@localhost:8000/notes/#{@note._id}.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist

				_body = JSON.parse(body)
				_body.should.have.property('_id')
				_body.should.have.property('message')
				_body.should.have.property('_user')
				done()


		it 'should UPDATE with REST', (done) ->
			options = {
				url 	: "http://test%40pine.io:pinerocks@localhost:8000/notes/#{@note._id}.json"
				form 	: {
					message 	: 'feed the dog'
				}
			}

			request.put options, (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200

				_body = JSON.parse(body)
				_body.should.have.property 'message'
				_body.message.should.eql 'feed the dog'
				done()

		it 'should CREATE with REST', (done) ->
			options = {
				url 	: "http://test%40pine.io:pinerocks@localhost:8000/notes.json"
				form 	: {
					message 	: 'fix the shed'
				}
			}

			request.post options, (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200

				_body = JSON.parse(body)
				_body.should.have.property 'message'
				_body.message.should.eql 'fix the shed'
				done()

		it 'should DELETE with REST', (done) ->
			self = @
			request.del "http://test%40pine.io:pinerocks@localhost:8000/notes/#{@note._id}.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist
				Note.findOne {_id:self._id}, (err, item) ->
					should.not.exist err
					should.not.exist item
					done()

		afterEach (done) ->
			app.models.User.remove {}, (err) -> 
				app.models.Note.remove {}, done

	
