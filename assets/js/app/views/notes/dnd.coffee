App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View

	initialize: () ->
		@current_note_id = @options.id

		@acts_as_draggable $('#stage ul.notes_board li:not(.stacked)')
		@acts_as_droppable $('#stage ul.notes_board li')
		@acts_as_draggable $('#stage ul.notes_board li .subnote')
		# make the stage droppable for subnotes
		@droppable_body $('body')

	reload: () ->
		push_url window.location.pathname + "?" + window.location.search

	targeting_another_note: () ->
		true if @current_note_id

	is_subnote: () ->
		$(@srcElement).hasClass("subnote")


	#
	# Drag and Drop
	#

	droppable_body: (body) ->
		self = @

		body.on 'drop', (e) ->
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.
		
			note 				= $(self.srcElement)
			note_id			= note.attr('data-id')
			parent_id 	= $(self.srcElement).parent('li.sticky').attr('data-id')

			if note.hasClass("subnote") and note_id isnt parent_id
				if self.targeting_another_note()
					$.getJSON "/notes/#{note_id}/restack/#{parent_id}/#{self.options.id}.json", (res) ->
						self.reload()
				else
					$.getJSON "/notes/#{note_id}/unstack/#{parent_id}.json", (res) ->
						self.reload()

				$(body).removeClass('drop')
				
			return false
		

		body.on 'dragenter', (e) ->
			if $(self.srcElement).hasClass("subnote")
				$(body).addClass('drop')
				$(self.srcElement).hide()
			return false

		body.on 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			# source 
			if $(self.srcElement).hasClass("subnote")
				$(body).addClass('drop')
				e.originalEvent.dataTransfer.dropEffect = 'copy'
			
			return false	

		body.on 'dragleave', (e) ->
			$(body).removeClass('drop') # this / e.target is previous target element.

	acts_as_droppable: (li) ->
		self = @

		li.on 'drop', (e) ->
			# this / e.target is current target element.
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.

			if self.is_subnote()
				note 		= $(self.srcElement)
				old_id  = $(self.draggable).attr('data-id')
			else
				note = $(self.draggable)

			if self.targeting_another_note()
				note 		= $(self.draggable) 
				old_id  = self.current_note_id

			note_id 	= note.attr('data-id')
			parent_id = $(this).attr('data-id')

			# stack unless the note we're stacking is the same as the note we're dragging
			unless this is self.draggable
				if old_id
					$.getJSON "/notes/#{note_id}/restack/#{old_id}/#{parent_id}.json", (res) ->
						self.reload()
				else
					$.getJSON "/notes/#{note_id}/stack/#{parent_id}.json", (res) ->
						self.reload()
			return false

		li.on 'dragenter', (e) ->
			# source 
			unless this is self.draggable
				$(this).addClass('stack')
			return false

		li.on 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			# source 
			unless this is self.draggable
				$(this).addClass('stack')
				e.originalEvent.dataTransfer.dropEffect = 'copy'
			return false	

		li.on 'dragleave', (e) ->
			$(this).removeClass('stack') # this / e.target is previous target element.


	acts_as_draggable: (li) ->
		self = @

		li.on 'dragstart', (e) ->
			self.draggable = this
			self.srcElement = $(e.srcElement)
			console.log self.srcElement
			e.originalEvent.dataTransfer.effectAllowed = 'all'
			e.originalEvent.dataTransfer.setData('Text', $(e.currentTarget).attr('data-id')) 
			this.style.opacity = '0.4'

		li.on 'dragend', (e) ->
			this.style.opacity = '1'

		
