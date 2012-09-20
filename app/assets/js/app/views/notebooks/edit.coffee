App.Views.Notebooks or= {}

class App.Views.Notebooks.Edit extends Backbone.View

	events:
		'submit form'					: 'submit'
		'click ul.colors li' 	: 'select_color'
		'click .delete' 			: 'delete'

	initialize: () ->
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
			success: (data, res) ->
				# close modal window
				$(self.el).modal('hide')
				$('input[name=name]', self.el).val("")
				$('input[name=color]', self.el).val("")
				# make the UI show the new notebook
				$("li[data-id=#{data.id}]").removeClass()
				$("li[data-id=#{data.id}]").addClass(data.attributes.color)
				$("li[data-id=#{data.id}]").attr('data-color', data.attributes.color)
				$("li[data-id=#{data.id}] a:first").html "@" + data.attributes.name
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
