App.Views.Notebooks or= {}

class App.Views.Notebooks.New extends Backbone.View

	events:
		'submit form' 				: 'submit'
		'click ul.colors li' 	: 'select_color'

	initialize: ->
		reset_events @
		@notebook = new App.Models.Notebook()
	
	render: ->
		$(@el).html ich.edit_notebook_content
			is_new: () -> true
		$(@el).modal()
		$(@el).on 'shown', () ->
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
				console.log data
				# close modal window
				$(self.el).modal('hide')
				$('input[name=name]', self.el).val("")
				notebook_html = "<li data-id='#{data.attributes._id}' data-name='#{data.attributes.name}' data-color='#{data.attributes.color}' class='#{data.attributes.color}'><a href='/notes?notebooks=#{data.attributes.name}' class='navigate'>@#{data.attributes.name}</a><a href='/notebooks/#{data.attributes._id}/edit' data-id='#{data.attributes._id}' class='push'><i class='icon-pencil'></i></a></li>"
				$('li.add-notebook:first').before(notebook_html)

				# reload the current path
				push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
