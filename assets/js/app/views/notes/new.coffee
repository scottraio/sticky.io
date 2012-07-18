App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'button[type=submit]'	: 'submit'
		'click .cancel'			: 'cancel'
	
	initialize: ->
		@note = new App.Models.Note()
		console.log @options.id

	render: () ->
		$(@el).modal('show')
		$('textarea', @el).focus()

		$('input.parent', @el).val(@options.id) 

		unless @options.id is undefined
			$('.is_parent', @el).show()
		else
			$('.is_parent', @el).hide()
			



	submit: (e) ->
		self = @
		attrs = {
			message: $('textarea', @el).val()
			parent_id: $('input.parent', @el).val()
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

	cancel: (e) ->
		$(@el).modal('hide')
		return false
