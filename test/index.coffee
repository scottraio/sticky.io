Mocha = require('mocha')
fs 		= require('fs')
path 	= require('path')
app 	= require "../app"

app.run (app) ->
	# First, you need to instantiate a Mocha instance.
	mocha = new Mocha
		timeout: 10000
		reporter: 'list'

	app.models.Note.remove {}
	app.models.User.remove {}
	app.models.Notebook.remove {}

	mocha.addFile(path.join('./test', 'notes_test.coffee'))
	mocha.addFile(path.join('./test', 'tags_test.coffee'))
	mocha.addFile(path.join('./test', 'bookmarks_test.coffee'))
	mocha.addFile(path.join('./test', 'notebooks_test.coffee'))

	# Now, you can run the tests.
	mocha.run () ->	
		process.exit()



