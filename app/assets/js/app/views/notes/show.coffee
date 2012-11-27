App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View

	events:
		'click .confirm' 								: 'confirm_delete'
		'click .make-bold'							: 'make_bold'
		'click .make-italic'						: 'make_italic'
		'click .make-underline' 				: 'make_underline'
		'click .save'										: 'save'
		'click #close-expanded-view' 		: 'close'
		'mouseover .drag-handle'				: 'make_draggable'
		'mouseout .drag-handle'					: 'make_undraggable'

	initialize: ->
		# set the id to the DOM
		$(@el).attr('data-id', @options.id)

		# select the note inside the inbox
		$('#inbox li.sticky').removeClass('selected')


		@note 			= new App.Models.Note(id: @options.id)
		@note.url 	= "/notes/#{@options.id}/expanded.json"

	render: () ->
		self = @

		$("ul.notes_board li").removeClass('selected')
		$("ul.notes_board li[data-id=#{@options.id}]").addClass('selected')

		@note.fetch
			success: (err, notesJSON) ->
				notes = []
				for note in notesJSON
					if note._id is self.options.id
						parent = note
					else
						notes.push note
			
				# Do some post-processing work and format the notes i.e. displaying titles for domains
				collection = new App.Collections.Notes()
				collection.format_domains(notes)

				$('.expanded-view-anchor', self.el).html ich.expanded_note
					parent_note 				: parent
					notes 							: notes
					note_message 				: () -> this.message && this.message.replace(/(<[^>]+) style=".*?"/g, '$1')
					has_subnotes				: () -> true if parent._notes && parent._notes.length > 0
					stacked_at_in_words	: () -> this.stacked_at && $.timeago(this.stacked_at)
					stacked_at_in_date 	: () -> format_date(this.stacked_at)
			
				# set the editable message with the parent note's message
				#$('#editable-message', self.el).html(parent.message)
				$('#editable-message').focus()
				$('#editable-message').autolink()
				$('.subnote').autolink()
				$('body').attr('data-current-note-open', parent._id) 

				#set the timeline's height
				$('#expanded-view .timeline-wrapper').css('height', $('body').outerHeight() - $('.expanded-wrapper').outerHeight() - $('.expanded-actions').outerHeight() - 60)

				# Drag and Drop
				window.dnd.droppable $('#expanded-view')
				window.dnd.draggable $('#expanded-view ul.timeline li')


	save: () ->	
		@note = new App.Models.Note(id: @options.id)
		save @note, { message : $('#editable-message', self.el).html() }, {
			success: (data, res) ->
				$('#save-notice').removeClass('hide')
				$('#save-notice').html('Saved')
			error: (data, res) ->
				console.log 'error'
		}
		return false

	close: (e) ->
		$('.expanded-view-anchor', @el).html('')
		$('body').attr('data-current-note-open', null)
		return false

	make_draggable: (e) ->
		$(e.currentTarget).parents('.subnote').attr('draggable', true)
		return false

	# autosave
	# events 'keyup #editable-message' : 'autosave'
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

	make_draggable: (e) ->
		$(e.currentTarget).parents('li').attr('draggable', true)
		return false

	make_undraggable: (e) ->
		$(e.currentTarget).parents('li').attr('draggable', false)
		return false

	
		
		


