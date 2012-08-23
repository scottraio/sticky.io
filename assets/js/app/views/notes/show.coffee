App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View

	events:
		'click .delete' 					: 'delete'
		'click .make-bold'				: 'make_bold'
		'click .make-italic'			: 'make_italic'
		'click .make-underline' 	: 'make_underline'
		'keyup #editable-message' : 'autosave'

	initialize: ->
		@note 			= new App.Models.Note(id: @options.id)
		@note.url 	= "/notes/#{@options.id}/expanded.json"

	render: () ->
		self = @
		@note.fetch 
			success: (err, notesJSON) -> 
				notes = []
				for note in notesJSON
					if note._id is self.options.id
						parent = note 
					else
						notes.push note
			
				$(self.el).html ich.expanded_note
					parent_note : parent
					notes 			: notes
					stacked_at_in_words	: () -> this.stacked_at && $.timeago(this.stacked_at)

				$('#editable-message', self.el).html(parent.message)
				#$('#editable-message', self.el).autosize()

	autosave: (e) ->
		self 	= @	
		@note = new App.Models.Note(id: @options.id)
		idle 	= 0
		clearTimeout(@timer)
	

		@timer = setTimeout((->
			save self.note, { message : $('#editable-message', self.el).html() }, {
				success: (data, res) ->
					$('#save-notice').html('Saved')
					self.timer = setTimeout((->						
						$('#save-notice').html('')
					), 3000)
				error: (data, res) ->
					console.log 'error'
			}
		), 3000)

	make_bold: (e) ->
		document.execCommand('bold',false,null)
		return false

	make_italic: (e) ->
		document.execCommand('italic', false, null)
		return false

	make_underline: (e) ->
		document.execCommand('underline', false, null)
		return false

	delete: (e) ->
			self = @
			note_id = $(e.currentTarget).attr('data-id')
			note = new App.Models.Note(id: note_id)
			note.destroy
				success: (model, res) ->
					# clear the html from the expanded view
					$(self.el).html('')
					# remove the sticky from the inbox
					$("li.sticky[data-id=#{note_id}]").remove()
			return false

