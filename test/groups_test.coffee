should  	= require 'should'
Browser		= require 'zombie'
request 	= require 'request'
mock 		= require './helpers/mocks'
provided 	= require './helpers/provided'
regex 		= require '../lib/regex'
Note 		= app.models.Note
Group 		= app.models.Group
User 		= app.models.User

describe 'Group', () ->

	describe 'regex matching', () ->

		it 'should be able to match a single group from string', (done) ->
			matches = "@apt14 need to pick up milk".match regex.match.group
			matches.should.be.an.instanceof Array
			matches.should.eql ['@apt14']

			matches = "need to pick up milk @apt14".match regex.match.group
			matches.should.be.an.instanceof Array
			matches.should.eql [' @apt14']

			done()

		it 'should be able to match mulitple groups from string', (done) ->
			matches = "pick up milk @apt14 @family".match regex.match.group
			
			matches.should.be.an.instanceof Array
			matches.should.eql [' @apt14', ' @family']
			
			done()

		it 'should be able to parse notes', (done) ->
			groups = []
			note = new app.models.Note(message: "@apt14 pick up milk")
			note.parse_groups()
			
			note.tags.should.be.an.instanceof Array

			# for some reason mongoose is not returning 
			# an array of strings, so we convert it
			for group in note.groups
				groups.push group

			groups.should.eql ['apt14']
			
			done()


	describe 'restful JSON API', () ->

		beforeEach (done) ->
			provided.we_have_a_group @, done

		it 'should return valid JSON for INDEX', (done) ->
			request.get "http://test%40pine.io:pinerocks@localhost:8000/groups.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist

				_body = JSON.parse(body)
				_body.should.be.an.instanceof Array
				done()

		it 'should return valid JSON for SHOW', (done) ->
			request.get "http://test%40pine.io:pinerocks@localhost:8000/groups/#{@group._id}.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist
				done()


		it 'should UPDATE with REST', (done) ->
			options = {
				url 	: "http://test%40pine.io:pinerocks@localhost:8000/groups/#{@group._id}.json"
				form 	: {
					name 	: 'workory'
					members : ['test@pine.io']
				}
			}

			request.put options, (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200

				_body = JSON.parse(body)
				_body.should.have.property 'name'
				_body.name.should.eql 'workory'
				done()

		it 'should CREATE with REST', (done) ->
			options = {
				url 	: "http://test%40pine.io:pinerocks@localhost:8000/groups.json"
				form 	: {
					name 	: 'workory'
					members : ['test@pine.io']
				}
			}

			request.post options, (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200

				_body = JSON.parse(body)
				_body.should.have.property 'name'
				_body.name.should.eql 'workory'
				done()

		it 'should DELETE with REST', (done) ->
			self = @
			request.del "http://test%40pine.io:pinerocks@localhost:8000/groups/#{@group._id}.json", (err, res, body) ->
				should.not.exist err
				res.should.be.json
				res.statusCode.should.eql 200
				body.should.exist
				Group.findOne {_id:self._id}, (err, item) ->
					should.not.exist err
					should.not.exist item
					done()

		afterEach (done) ->
			app.models.User.remove {}, (err) -> 
				app.models.Group.remove {}, done

	
