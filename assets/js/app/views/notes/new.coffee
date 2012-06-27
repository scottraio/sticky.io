App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'button[type=submit]'	: 'submit'
	
	initialize: ->
		@note = new App.Models.Note()

	render: () ->
		$(@el).modal('show')
		$('textarea', @el).focus()

	submit: (e) ->
		self = @
		attrs = {
			message: $('textarea', @el).val()
		}

		save @note, attrs, {
			success: (data, res) ->
				# close modal window
				$(self.el).modal('hide')
				$('textarea', self.el).val("")
				# reload the current path
				push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
	
		