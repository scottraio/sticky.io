should  	= require 'should'
Browser		= require 'zombie'
request 	= require 'request'
mock 			= require './helpers/mocks'
provided 	= require './helpers/provided'
regex 		= require '../lib/sticky-regex'
Note 			= app.models.Note
User 			= app.models.User


describe 'Bookmarks', () ->

	describe 'regex matching', () ->

		it 'should be able to match a single domain from string', (done) ->
			matches = "mongodb osx quickstart http://www.sticky.io".match regex.match.link
			matches.should.be.an.instanceof Array
			matches.should.eql ['http://www.sticky.io']

			done()

		it 'should be able to match mulitple domains from string', (done) ->
			matches = "pick up milk http://www.sticky.io http://www.workory.com".match regex.match.link
			
			matches.should.be.an.instanceof Array
			matches.should.eql ['http://www.sticky.io', 'http://www.workory.com']
			
			done()

		it 'should be able to match funky domains', (done) ->
			matches = "http://www.mongodb.org/display/DOCS/Quickstart+OS+X".match regex.match.link
			matches.should.be.an.instanceof Array
			matches.should.eql ['http://www.mongodb.org/display/DOCS/Quickstart+OS+X']
			
			done()

		it 'should be able to parse notes', (done) ->
			links = []
			note = new app.models.Note(message: "http://www.mongodb.org/display/DOCS/Quickstart+OS+X", _user: mock.user._id)
			
			#
			# Parse it!
			note.parse()
			
			note.links.should.be.an.instanceof Array

			# TODO: test for domain creation
			# for some reason mongoose is not returning 
			# an array of strings, so we convert it
			#for link in note.links
			#	links.push link
			#
			#
			#links.should.eql ['http://www.mongodb.org/display/DOCS/Quickstart+OS+X']
			
			done()

