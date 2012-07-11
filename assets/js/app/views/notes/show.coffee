App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View
	
	initialize: ->
		@note 		= new App.Models.Note(id: @options.id)
		@note.url 	= "/notes/#{@options.id}/expanded.json"

	render: () ->
		self = @
		@note.fetch 
			success: (err, notesJSON) -> 
				console.log notesJSON
				index = new App.Views.Notes.Index(el: $("#main"), id: self.options.id)
				index.load_view(notesJSON)