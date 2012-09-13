App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View

	initialize: () ->

	reload: () ->
		push_url window.location.pathname + "?" + window.location.search
		if @is_note_open()
			push_url("/notes/#{@current_note_id}")

	is_note_open: () ->
		# return true if we've expanded a note into the expanded view
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
		
			note 				= $(self.draggable)
			note_id			= note.attr('data-id')
			parent_id 	= self.current_note_id

			if self.is_note_open() and self.is_subnote() and note_id isnt parent_id
				$.getJSON "/notes/#{note_id}/unstack/#{parent_id}.json", (res) ->
					$(body).removeClass('drop')
					self.reload()
				
			return false
		

		body.on 'dragenter', (e) ->
			if self.is_note_open() and self.is_subnote()
				$(body).addClass('drop')
				$(self.srcElement).hide()
			return false

		body.on 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			# source 
			if self.is_subnote()
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

			parent = $(this)

			if self.is_subnote()
				# if the note being dragged is a subnote, then use the srcElement,
				# its the item being dragged
				child 	= $(self.srcElement)
				old_id  = $(self.draggable).attr('data-id')
			else
				# otherwise use the draggable
				child 	= $(self.draggable)

			if self.is_note_open()
				old_id  = self.current_note_id

			child_id 	= child.attr('data-id')
			parent_id = parent.attr('data-id')

			# stack unless the note we're stacking is the same as the note we're dragging
			unless this is self.draggable
				if old_id # restacking
					$.getJSON "/notes/#{child_id}/restack/#{old_id}/#{parent_id}.json", (res) ->
						self.reload()
						$("ul.timeline li[data-id=#{child_id}]").remove()
						parent.removeClass('stack')
				else
					$.getJSON "/notes/#{child_id}/stack/#{parent_id}.json", (res) ->
						self.reload()
						parent.removeClass('stack')
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
			
			e.originalEvent.dataTransfer.effectAllowed = 'all'
			e.originalEvent.dataTransfer.setData('Text', $(e.currentTarget).attr('data-id')) 
			$(this).addClass('dragging')


		li.on 'dragend', (e) ->
			$(this).removeClass('dragging')
		
