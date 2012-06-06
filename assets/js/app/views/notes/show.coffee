App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View
	
	events:
		'click .delete' : 'delete'
	
	initialize: ->
		@note = new App.Models.Note(id: @options.id)

	render: () ->
		self = @
		@note.fetch 
			success: (err, noteJSON) -> 
				$(self.el).modal('show')
				$(self.el).html ich.note_details(noteJSON)

				# make it easy for our users to read their posts
				$(self.el).autolink()
				$(self.el).autotag()

	delete: (e) ->
		self = @
		@note.destroy
			success: (model, res) ->
				# close modal window
				$(self.el).modal('hide')
				# reload the form
				push_url '/'
		return false
