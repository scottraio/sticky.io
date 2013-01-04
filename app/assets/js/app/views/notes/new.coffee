App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'keypress' 										: 'detect_enter_key'
		'click #close-expanded-view' 	: 'close'
	
	initialize: ->
		@note = new App.Models.Note()



	render: () ->
		$('.expanded-view-anchor', @el).html TEMPLATES['expanded']
			parent_note : null
			notes 			: []
			new_note		: true

		$(@el).show()
		$('#editable-message').focus()

		#$(@el).on 'shown', () ->
			#$('#new-note-input', @el).val('')
			#$('#new-note-input', @el).focus()
		#$(@el).modal('show')
	
	detect_enter_key: (e) ->
		if e.keyCode is 13 && !e.shiftKey
			@submit()
	
	close: (e) ->
		$(@el).hide()
		$('.expanded-view-anchor', @el).html('')
		$('body').attr('data-current-note-open', null)
		return false

	submit: () ->
		self = @
		attrs = {
			message: $('#editable-message', self.el).html()
		}

		if attrs.message.length > 0
			save @note, attrs, {
				success: (data, res) ->
					# close modal window
					$(self.el).hide()
					
					# Removed in favor of SocketIO
					# reload the current path
					#	push_url window.location.pathname + window.location.search

				error: (data, res) ->
					console.log 'error'
			}
		
		return false