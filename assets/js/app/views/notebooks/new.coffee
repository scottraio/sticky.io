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
			name: $('input', @el).val()
			members: $('textarea', @el).val()
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
