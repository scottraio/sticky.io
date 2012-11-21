App.Views.Notebooks or= {}

class App.Views.Notebooks.Edit extends Backbone.View

	events:
		'submit form'					: 'submit'
		'click ul.colors li' 	: 'select_color'
		'click .delete' 			: 'delete'

	initialize: () ->
		self = @
		reset_events @
 
		@notebook = new App.Models.Notebook(id: @options.id)
	
	render: () ->
		self = @

		@notebook.fetch
			success: (err, notebookJSON) ->
				$(self.el).html ich.edit_notebook_content(notebook: notebookJSON[0], is_new: () -> false)
				$(self.el).modal()
				$("li[data-value=#{notebookJSON[0].color}]").addClass('selected')
				$(self.el).on 'shown', () ->
					$('input[name=name]', @el).focus()

	select_color: (e) ->
		# set the input
		color = $(e.currentTarget).attr('data-value')
		$('input[name=color]').val color
		# now show the color as being selected
		$('ul.colors li').removeClass('selected')
		$(e.currentTarget).addClass('selected')
		return false

	submit: (e) ->
		self 	= @
		attrs = {
			name: $('input[name=name]', @el).val()
			color: $('input[name=color]', @el).val()
		}
		
		save @notebook, attrs, {
			success: (notebook, res) ->
				# close modal window
				self.update_ui(notebook)
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
				$('#notebook').modal('hide')
		return false

	update_ui: (notebook) ->
		$(@el).modal('hide')
		$('input[name=name]', @el).val("")
		$('input[name=color]', @el).val("")
		# make the UI show the new notebook
		$(".notebooks li[data-id=#{notebook.id}]").removeClass()
		$(".notebooks li[data-id=#{notebook.id}]").addClass('notebook')
		$(".notebooks li[data-id=#{notebook.id}]").addClass(notebook.attributes.color)
		$(".notebooks li[data-id=#{notebook.id}]").attr('data-color', notebook.attributes.color)
		$(".notebooks li[data-id=#{notebook.id}]").attr('data-name', notebook.attributes.name)
		$(".notebooks li[data-id=#{notebook.id}] a:first").html "@" + notebook.attributes.name