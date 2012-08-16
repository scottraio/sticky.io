App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View


	initialize: ->
		@note 			= new App.Models.Note(id: @options.id)
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
			
				$(self.el).html ich.expanded_note
					parent_note : parent
					notes 			: notes
					stacked_at_in_words	: () -> $.timeago(this.stacked_at)


				$('textarea', self.el).autosize()

