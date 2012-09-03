App.Views.Notebooks or= {}

class App.Views.Notebooks.Edit extends Backbone.View

	events:
		"submit form" : "submit"

	initialize: () ->
		reset_events @
		@notebook = new App.Models.Notebook(id: @options.id)
	
	render: () ->
		self = @

		@notebook.fetch
			success: (err, notebookJSON) ->
				$(self.el).html ich.edit_notebook_content(notebook: notebookJSON[0])
				$(self.el).modal()

	submit: (e) ->
		self 	= @
		attrs = {
			name: $('input', @el).val()
			members: $('textarea', @el).val().split(',')
		}
		
		save @notebook, attrs, {
			success: (data, res) ->
				# close modal window
				$(self.el).modal('hide')
				$('input[name=name]', self.el).val("")
				# reload the current path
				push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
