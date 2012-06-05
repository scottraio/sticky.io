app = require '../app'


# Clear notes from all tags
app.models.Note.find {}, (err, notes) ->
	for note in notes

		new_tags = []
		tag_regex = /[#]+[A-Za-z0-9-_]+/g
		while ((tags = tag_regex.exec(note.message)) != null)
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			new_tags.push tags[0].substring(1)

		note.set 'tags', new_tags
		note.save (err) ->
			console.log err if err

console.log 'All finished'

# TODO: figure out how to async kill this task when its finished
