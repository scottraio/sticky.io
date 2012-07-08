App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View
	
	initialize: ->
		@note = new App.Models.Note(id: @options.id)

	render: () ->
		self = @
		@note.fetch 
			success: (err, noteJSON) -> 
				$(self.el).html ich.single_note
					note				: noteJSON
					created_at_in_words	: () -> $.timeago(this.created_at)
				
				# make it easy for our users to read their posts
				$(self.el).autolink()
				return noteJSON


