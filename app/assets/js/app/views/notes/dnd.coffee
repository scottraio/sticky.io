App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View

	initialize: () ->
		self = @

		# 
		# Socket.IO
		socket.on 'ui:cleanup:empty_stack', (parent) ->
			self.cleanup_empty_stack(parent._id)

		# 
		# Socket.IO
		socket.on 'notes:subnote:add', (data) ->
			
			if self.current_open_note_id() is data._parent
				$('ul.timeline').append ich.substicky
						note_message 				: () -> data.message && data.message.replace(/(<[^>]+) style=".*?"/g, '$1')
						stacked_at_in_words	: () -> data.stacked_at && $.timeago(data.stacked_at)
						stacked_at_in_date 	: () -> format_date(data.stacked_at)


	is_note_open: () ->
		# return true if we've expanded a note into the expanded view
		true if @current_open_note_id() && @current_open_note_id().length > 0

	is_subnote: () ->
		$(@srcElement).hasClass("subnote")

	current_open_note_id: () ->
		$('body').attr('data-current-note-open')

	dropping_subnote_on_its_parent: (droppable) ->
		true if $(droppable).attr('id') is 'expanded-view' and @is_subnote()


	#
	# Drag and Drop
	droppable_body: () ->
		self = @
		body = $('body')
		
		body.on 'drop', (e) ->
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.
			self.unstack(this) if self.is_note_open() and self.is_subnote()
			return false
		
		body.on 'dragenter', (e) ->
			if self.is_note_open() and self.is_subnote()
				$(body).addClass('drop')
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

	droppable: (li) ->
		self = @
		li.on 'drop', (e) ->
			
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.
			# stack unless the note we're stacking is the same as the note we're dragging
		
			unless this is self.child or self.dropping_subnote_on_its_parent(this) 
				if self.is_note_open() and $(@child).hasClass("subnote") # restacking
					self.restack(this)
				else
					self.stack(this)
			return false

		li.on 'dragenter', (e) ->
			unless this is self.draggable or self.dropping_subnote_on_its_parent(this) 
				$(this).addClass('stack')
			return false

		li.on 'dragover', (e) ->
			e.preventDefault() if e.preventDefault # Necessary. Allows us to drop.
			# source 
			unless this is self.child or self.dropping_subnote_on_its_parent(this) 
				self.make_desirable(e, this)
			return false	

		li.on 'dragleave', (e) ->
			self.make_undesirable(e, this)


	draggable: (li) ->
		self = @

		li.on 'dragstart', (e) ->
			self.srcElement = $(e.srcElement)
			self.child 			= this

			e.originalEvent.dataTransfer.effectAllowed = 'all'
			e.originalEvent.dataTransfer.setData('Text', $(e.currentTarget).attr('data-id')) 
			$(e.dragProxy).addClass('dragging')

		li.on 'dragend', (e) ->
			$(this).removeClass('dragging')



	#
	# Unstack
	unstack: (body) ->
		self 				= @
		child_id 		= $(@child).attr('data-id')
		parent_id 	= @current_open_note_id()

		# Use Socket.IO to emit unstack event
		socket.emit 'notes:unstack', {child_id: child_id, parent_id: parent_id}
		
		# cleanup
		$(body).removeClass('drop')
		$("li[data-id=#{child_id}]").remove()

	#
	# Restack
	restack: (parent) ->
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')
		old_id			= @current_open_note_id()

		# Use Socket.IO to emit unstack event
		socket.emit 'notes:restack', {child_id: child_id, old_id: old_id, parent_id: parent_id}
		
		# cleanup
		$("li[data-id=#{child_id}]").remove()
		$(parent).removeClass('stack')
		
	#
	# Stack
	stack: (parent) ->
		self 				= @
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')

		# Use Socket.IO to emit unstack event
		socket.emit 'notes:stack', {child_id: child_id, parent_id: parent_id}
		
		# cleanup
		if self.current_open_note_id() is parent_id # if we dragging onto a note thats open
			self.merge_onto_open_note(parent)
		else
			self.cleanup_fresh_stack(parent)
		
		self.make_fresh_stack(parent)
	


	#
	# UI Cleanup duty
	make_desirable: (e, parent) ->
		$(parent).addClass('stack')
		e.originalEvent.dataTransfer.dropEffect = 'copy'

	make_undesirable: (e, parent) ->
		$(parent).removeClass('stack')

	merge_onto_open_note: (parent) ->
		parent_id = $(parent).attr('data-id')

		# remove the child
		$(@child).remove()

		# clean up UI
		$("[data-id=#{parent_id}]").removeClass('stack')

	make_fresh_stack: (parent) ->
		parent_id = $(parent).attr('data-id')
		child_id 	= $(@child).attr('data-id')

		# Make stacked
		card = $("li[data-id=#{parent_id}]")
		card.addClass('stacked')
		# populate the view with the new stack actions
		card.prepend ich.sticky_actions 
			draggable 		: false
			has_subnotes 	: true
			_id						: parent_id
		
	cleanup_fresh_stack: (parent) ->
		parent_id = $(parent).attr('data-id')
		child_id 	= $(@child).attr('data-id')

		# remove the child
		$(@child).remove()
		# clean up UI
		$("[data-id=#{parent_id}]").removeClass('stack')
		$(".sticky-actions","li[data-id=#{parent_id}]").remove()

	# when we've unstacked every note, we want to remove the 'stacked' status
	# from the parent note in the list
	cleanup_empty_stack: (parent_id) ->
		# clean up UI
		parent = $("ul.notes_board li[data-id=#{parent_id}]")
		parent.removeClass('stack')
		$(".sticky-actions", parent).remove()
