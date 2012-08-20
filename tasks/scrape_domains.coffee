app = require '../app'


# Clear notes from all tags
app.models.Note.find {}, (err, notes) ->
	

	for note in notes
		console.log note.links
		for link in note.links
			domain = new app.models.Domain()
			domain.crawl link, note, (err, domain) ->
				console.log err if err
				console.log domain
				note._domains.push domain._id
				note.save (err) ->
					console.log err if err


console.log 'All finished'

# TODO: figure out how to async kill this task when its finished
