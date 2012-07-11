app = require '../app'


# Clear notes from all tags
app.models.Note.find {}, (err, notes) ->
	for note in notes
		note.set '_notes', []
		note.set '_parent', null
		note.save (err) ->
			console.log err if err

console.log 'All finished'

# TODO: figure out how to async kill this task when its finished
