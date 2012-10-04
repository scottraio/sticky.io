mock = require './mocks'

exports.we_have_an_user = (test,cb) ->
	self 				= test
	self.user 	= new app.models.User(mock.user)
	self.user.save cb

exports.we_have_a_note = (test,cb) ->
	self = test
	exports.we_have_an_user test, (err) ->
		unless err
			app.models.Note.create_note self.user, mock.note.message, (err,note) ->
				self.note = note
				cb(err)
		else
			cb(err)

exports.we_have_a_notebook = (test,cb) ->
	self = test
	exports.we_have_an_user test, (err) ->
		unless err
			self.notebook 							= new app.models.Notebook(mock.notebook)
			self.notebook._owner 				= self.user._id
			self.notebook.save (err) ->
				cb(err)
		else
			cb(err)