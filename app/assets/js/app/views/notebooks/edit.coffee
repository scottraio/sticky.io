App.Views.Notebooks or= {}

class App.Views.Notebooks.Edit extends Backbone.View

	events:
		'submit form'			: 'submit'
		'click .delete' 	: 'delete'

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
			name: $('input[name=name]', @el).val()
			color: $('select[name=color]', @el).val()
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

	delete: (e) ->
		notebook_id = $(e.currentTarget).attr('data-id')
		notebook 		= new App.Models.Notebook(id: notebook_id)
		notebook.destroy
			success: (model, res) ->
				# remove the sticky from the inbox
				$("ul.notebooks li[data-id=#{notebook_id}]").remove()
				$('#edit-notebook').modal('hide')
		return false
