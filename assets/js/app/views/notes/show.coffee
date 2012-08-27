App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View

	events:
		'click .confirm' 					: 'confirm_delete'
		'click .make-bold'				: 'make_bold'
		'click .make-italic'			: 'make_italic'
		'click .make-underline' 	: 'make_underline'
		'keyup #editable-message' : 'autosave'
		'click .save'							: 'save'

	initialize: ->
		# select the note inside the inbox
		$('#inbox li.sticky').removeClass('selected')

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
			
				$('#stage').html ich.expanded_note
					parent_note : parent
					notes 			: notes
					has_subnotes				: () -> true if parent._notes && parent._notes.length > 0
					stacked_at_in_words	: () -> this.stacked_at && $.timeago(this.stacked_at)
					stacked_at_in_date 	: () -> self.format_date(this.stacked_at)

				$('#editable-message', self.el).html(parent.message)
				$('#editable-message').focus()


	save: () ->	
		@note = new App.Models.Note(id: @options.id)
		save @note, { message : $('#editable-message', self.el).html() }, {
			success: (data, res) ->
				$('#save-notice').html('Saved')
				@timer = setTimeout((->						
					$('#save-notice').html('')
				), 3000)
			error: (data, res) ->
				console.log 'error'
		}
		return false

	autosave: (e) ->
		self 	= @	
		idle 	= 0
		clearTimeout(@timer)
	
		@timer = setTimeout((->
			self.save()
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

	confirm_delete: (e) ->
		$('#delete-note').attr('data-id', $(e.currentTarget).attr('data-id')).modal()
		return false

	format_date: (date) ->
		date = new Date(date)
		return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear()
