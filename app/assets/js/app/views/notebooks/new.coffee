App.Views.Notebooks or= {}

class App.Views.Notebooks.New extends Backbone.View

	events:
		"submit form" : "submit"

	initialize: ->
		@notebook = new App.Models.Notebook()
	
	render: ->
		$(@el).modal()

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
				notebook_html = "<li><a href='/notes?notebooks=#{data.attributes.name}' class='navigate'>@#{data.attributes.name}</a><a href='/notebooks/#{data.attributes._id}/edit' data-id='#{data.attributes._id}' class='push'><i class='icon-pencil'></i></a></li>"
				$('li.add-notebook').before(notebook_html)

				# reload the current path
				push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
