App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View
	
	initialize: ->
		@note = new App.Models.Note(id: @options.id)

	render: () ->
		self = @
		@note.fetch 
			success: (err, noteJSON) -> 
				index = new App.Views.Notes.Index(el: $("#main"), id: self.note.id)
				index.load_view(noteJSON)