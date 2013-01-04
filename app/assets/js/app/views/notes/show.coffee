App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View

	keyboardEvents:
		'command+alt+s'	: 'save'
		'command+alt+w'	: 'close'

	events:
		'click .confirm' 								: 'confirm_delete'
		'click .make-bold'							: 'make_bold'
		'click .make-italic'						: 'make_italic'
		'click .make-underline' 				: 'make_underline'
		'click #close-expanded-view' 		: 'close'		
		'mouseover .drag-handle'				: 'make_draggable'
		'mouseout .drag-handle'					: 'make_undraggable'

	initialize: ->
		self = @

		# 
		# Brief aside on super: JavaScript does not provide a simple way to call super — 
		# the function of the same name defined higher on the prototype chain.
		Backbone.View.prototype.initialize.apply(@, arguments);

		#
		# set the id to the DOM
		$(@el).attr('data-id', @options.id)

		# 
		# clear autosave eventss
		$('#editable-form').trigger('autosave.shutdown');

		#
		# select the note inside the inbox
		$('#inbox li.sticky').removeClass('selected')

		# 
		# build the note object
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

				$('.expanded-view-anchor', self.el).html TEMPLATES['expanded']
					parent_note : parent
					notes 			: notes
					new_note		: false
			
				self.after_ui_hook(parent, notes)


	save: () ->	
		@note = new App.Models.Note(id: @options.id)
		save @note, { message : $('#editable-message').html() }, {
			success: (data, res) ->
				$('#save-notice').removeClass('hide')
				$('#save-notice').html('Saved')
			error: (data, res) ->
				console.log 'error'
		}
		return false

	close: (e) ->
		$(@el).hide()
		$('.expanded-view-anchor', @el).html('')
		$('body').attr('data-current-note-open', null)
		#
		# unbind keyboard events when we close the view
		@unbindKeyboardEvents()
		return false

	make_draggable: (e) ->
		$(e.currentTarget).parents('.subnote').attr('draggable', true)
		return false

	after_ui_hook: (parent, notes) ->
		$(@el).show()
		# set the editable message with the parent note's message
		#$('#editable-message', self.el).html(parent.message)
		$('#editable-message').focus()
		$('.subnote').autolink()

		# set the body open note to parent note
		$('body').attr('data-current-note-open', parent._id) 

		#
		# set the timeline's height & scroll to the bottom
		height = $('.expanded-wrapper').outerHeight() + $('.expanded-actions').outerHeight() + $('.timeline-wrapper').outerHeight() + 10
		height = 500 if height > 500
		$('#expanded-view').css('height', height)

		wrapper_height = height - ($('.expanded-actions').outerHeight() + $('.expanded-wrapper').outerHeight())
		$('#expanded-view .timeline-wrapper').css('height', wrapper_height)


		$('#expanded-view .timeline-wrapper').scrollTop $('#expanded-view').height()

		#
		# Drag and Drop
		window.dnd.droppable $('#expanded-view')
		window.dnd.draggable $('#expanded-view ul.timeline li')

		#
		# setup subnote events - aka adding subnotes view
		new_note = new App.Views.Notes.Push(el: $('.add-subnote'), id: parent._id)

		#
		# Make the new subnote box autosizable
		$('#expanded-view ul.timeline textarea').autosize()

		#
		# Autosave!
		$('#editable-form').autosave
			interval:2000,
			url:"/notes/#{parent._id}.json",
			method:'PUT',
			save: (e,o) ->
				console.log 'saved'
			before: (e,o) ->
				$('#editable-form textarea').val $('#editable-message').html()

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

	
		
		


