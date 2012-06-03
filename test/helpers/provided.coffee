mock = require './mocks'

exports.we_have_an_user = (test,cb) ->
	self = test
	self.user = new app.models.User(mock.user)
	self.user.save cb

exports.we_have_a_note = (test,cb) ->
	self = test
	exports.we_have_an_user test, (err) ->
		unless err
			self.note 			= new app.models.Note(mock.note)
			self.note._user 	= self.user._id
			self.note.save (err) ->
				cb(err)
		else
			cb(err)
