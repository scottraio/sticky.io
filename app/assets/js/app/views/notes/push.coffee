App.Views.Notes or= {}

class App.Views.Notes.Push extends Backbone.View
	
	events:
		'keypress' 					: 'detect_enter_key'
	
	initialize: ->
		@note = new App.Models.Note()
		@note.url = "/notes/#{@options.id}/push.json"
	
	detect_enter_key: (e) ->
		if e.keyCode is 13 && !e.shiftKey
			@submit()
			
	submit: () ->
		self = @
		attrs = {
			message: $('textarea', @el).val()
		}

		if attrs.message.length > 0
			save @note, attrs, {
				success: (data, res) ->
					$('textarea', @el).val('')
					# close modal window
					$(self.el).before ich.substicky
						note_message 				: () -> data.attributes.message && data.attributes.message.replace(/(<[^>]+) style=".*?"/g, '$1')
						stacked_at_in_words	: () -> data.attributes.stacked_at && $.timeago(data.attributes.stacked_at)
						stacked_at_in_date 	: () -> format_date(data.attributes.stacked_at)
						is_taskable					: () -> true if data.attributes.message && data.attributes.message.indexOf('#todo') > 0
					
					# Removed in favor of SocketIO
					# reload the current path
					#	push_url window.location.pathname + window.location.search

				error: (data, res) ->
					console.log 'error'
			}
		
		return false