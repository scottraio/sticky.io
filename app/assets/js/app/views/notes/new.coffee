App.Views.Notes or= {}

class App.Views.Notes.New extends Backbone.View
	
	events:
		'keypress' 					: 'detect_enter_key'
		'focus'							: 'focus_new_sticky'
		'blur'							: 'blur_new_sticky'
	
	initialize: ->
		@note = new App.Models.Note()
	
	detect_enter_key: (e) ->
		if e.keyCode is 13 && !e.shiftKey
			@submit()
			

	submit: () ->
		self = @
		attrs = {
			message: $(@el).html()
		}

		save @note, attrs, {
			success: (data, res) ->
				# close modal window
				$(self.el).html("")
				$(self.el).blur()
				$('body').click()

				# Removed in favor of SocketIO
				# reload the current path
				#	push_url window.location.pathname + window.location.search

			error: (data, res) ->
				console.log 'error'
		}
		
		return false

	focus_new_sticky: (e) ->
		new_message = $(e.currentTarget)
		new_message.removeClass('idle')
		if (new_message[0].hasChildNodes() && document.createRange && window.getSelection)
			$(new_message).empty()
			range = document.createRange()
			range.selectNodeContents(new_message[0])
			sel = window.getSelection()
			sel.removeAllRanges()
			sel.addRange(range)

	blur_new_sticky: (e) ->
		new_message = $(e.currentTarget)
		if new_message.html() is ''	
			new_message.html "What's on your mind?"
			new_message.addClass 'idle'
		return false

