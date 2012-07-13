App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'button[type=submit]'	: 'submit'
		'click .cancel'			: 'cancel'
	
	initialize: ->
		@note = new App.Models.Note()

	render: () ->
		$(@el).modal('show')
		$('textarea', @el).focus()

		parent_id = window.location.pathname.replace('/notes/', '')
		if parent_id.length > 0
			$('input.parent', @el).val(parent_id) 
			$('.is_parent', @el).show()

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
	
		