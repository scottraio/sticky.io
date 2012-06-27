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
				# make the textarea's height the same height as the autolink height
				height = $('.autolink', self.el).height()
				$(self.el).html("
					<textarea name=\"message\" style=\"height:#{height}px\">#{noteJSON.message}</textarea>
					<div class=\"meta meta-edit\">
						<a href=\"/notes/#{noteJSON._id}\" class=\"btn btn-mini btn-primary\">Save</a>
						<a href=\"/notes/#{noteJSON._id}\" class=\"push btn btn-mini\">Cancel</a>
					</div>
				")
				$('textarea', self.el).focus()
				

	submit: (e) ->
		self = @
		attrs = {
			message	: $('textarea', @el).val()
			_method : 'put'
		}

		save @note, attrs, {
			success: (data, res) ->
				# reload the sticky
				push_url "/notes/#{self.note.id}"

			error: (data, res) ->
				console.log 'error'
		}
		
		return false

	cancel: (e) ->
		push_url $(e.currentTarget).attr("href")
		return false

	
		