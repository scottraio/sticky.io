App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View


	initialize: ->
		@note 		= new App.Models.Note(id: @options.id)
		@note.url 	= "/notes/#{@options.id}/expanded.json"

	render: () ->
		self = @
		@note.fetch 
			success: (err, notesJSON) -> 
				notes = []
				for note in notesJSON
					if note._id is self.options.id
						parent = note 
					else
						notes.push note
					
				index = new App.Views.Notes.Index(el: $("#main"), id: self.options.id)
				index.load_view(notes)

				navigating_up = $(".crumb-bar a[href='/notes/#{parent._id}']").length > 0

				if navigating_up
					$(".crumb-bar a[href='/notes/#{parent._id}']").next("a").remove()
				else
					$(".crumb-bar").append("<a href=\"/notes/#{parent._id}\" class=\"navigate headline\">#{parent.message}</a>")

