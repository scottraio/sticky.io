App.Views.Notes or= {}

class App.Views.Notes.Edit extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'click .btn-primary'	: 'submit'
		'click .cancel' 		: 'cancel'
	
	initialize: ->
		@note = new App.Models.Note(id: @options.id)

	render: () ->
		self = @
		@note.fetch 
			success: (err, noteJSON) -> 
				$(self.el).modal('show')
				$(self.el).html ich.edit_note_details(noteJSON)
				$('textarea[name=message]').focus()
				

	submit: (e) ->
		self = @
		attrs = {
			message	: $('textarea', @el).val()
			_method : 'put'
		}

		save @note, attrs, {
			success: (data, res) ->
				# reload the form
				$(self.el).modal('hide')

			error: (data, res) ->
				console.log 'error'
		}
		
		return false

	cancel: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false
	
		