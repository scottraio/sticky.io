app = require '../app'

app.models.Note.find {}, (err, notes) ->
	for note in notes
		note.tags = []
		note.parse_tags()
		note.save (err) ->
			console.log err if err

console.log 'All finished'

# TODO: figure out how to async kill this task when its finished
