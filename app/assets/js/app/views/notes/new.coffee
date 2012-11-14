App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'keypress' 					: 'detect_enter_key'
	
	initialize: ->
		@note = new App.Models.Note()

	render: () ->
		$(@el).on 'shown', () ->
			$('textarea', @el).val('')
			$('textarea', @el).focus()

		$(@el).modal('show')

	
	detect_enter_key: (e) ->
		if e.keyCode is 13 && !e.shiftKey
			@submit()
			
	submit: () ->
		self = @
		attrs = {
			message: $('textarea', @el).val()
		}

		save @note, attrs, {
			success: (data, res) ->
				# close modal window
				$(self.el).modal('hide')
				
				# Removed in favor of SocketIO
				# reload the current path
				#	push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false