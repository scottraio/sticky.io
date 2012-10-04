should  	= require 'should'
Browser		= require 'zombie'
request 	= require 'request'
mock 			= require './helpers/mocks'
provided 	= require './helpers/provided'

regex 		= require '../lib/sticky-regex'
Note 			= app.models.Note
User 			= app.models.User

describe 'Tags', () ->

	describe 'regex matching', () ->

		it 'should be able to match a single tag from string', (done) ->
			matches = "pick up milk #todo".match regex.match.tag
			matches.should.be.an.instanceof Array
			matches.should.eql [' #todo']

			done()

		it 'should be able to match mulitple tags from string', (done) ->
			matches = "pick up milk #todo #food".match regex.match.tag
			
			matches.should.be.an.instanceof Array
			matches.should.eql [' #todo', ' #food']
			
			done()

		it 'should be able to match funky tags', (done) ->
			matches = "pick up milk #todo#tomorrow # #milk_sucks #milk-sucks # beverage #food".match regex.match.tag
			
			matches.should.be.an.instanceof Array
			matches.should.eql [' #todo#tomorrow', ' #milk_sucks', ' #milk-sucks', ' #food']
			
			done()

		it 'should be able to parse notes', (done) ->
			tags = []
			note = new app.models.Note(message: "pick up milk #todo #food", _user: mock.user._id)

			#
			# Simplify the message, somtimes HTML is sent over. Lets get rid of it and store the 
			# plain text version.
			note.simplify()

			#
			# Parse it!
			note.parse_tags()
			
			note.tags.should.be.an.instanceof Array

			# for some reason mongoose is not returning 
			# an array of strings, so we convert it
			for tag in note.tags
				tags.push tag

			tags.should.eql ['todo', 'food']
			
			done()


	# TODO: /tags.json should return a list of tags
	#
	#describe 'restful JSON API', () ->
	#
	#	beforeEach (done) ->
	#		provided.we_have_a_note @, done
	#
	#	it 'should return valid JSON for INDEX', (done) ->
	#		request.get "http://test%40pine.io:pinerocks@localhost:8000/tags.json", (err, res, body) ->
	#			#should.not.exist err
	#			#res.should.be.json
	#			res.statusCode.should.eql 200
	#			#body.should.exist
	#
	#			_body = JSON.parse(body)
	#			_body.should.be.an.instanceof Array
	#			done()
	#
	#
	#	afterEach (done) ->
	#		app.models.Note.remove {}, (err) -> 
	#			app.models.User.remove {}, done

	
