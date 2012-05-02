should  	= require 'should'
Browser		= require 'zombie'
mock 		= require './mocks'
User 		= app.models.User

describe 'User', () ->

	describe 'basic crud operations', () ->

		it 'should save without error', (done) ->
			user = new User(mock.user)
			user.save(done)

		afterEach (done) ->
			User.remove {}, done

	describe 'ensure authentication', () ->

		it 'should return status 200 ok on login page', (done) ->
			Browser.visit "http://localhost:8000/login", {debug: false}, done

