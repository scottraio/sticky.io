App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View

	initialize: () ->
		self = @

		# 
		# Socket.IO
		socket.on 'ui:cleanup:empty_stack', (parent) ->
			self.cleanup_empty_stack(parent._id)

		# add a subnote to the expanded view
		socket.on 'notes:subnote:add', (data) ->
			
			if self.current_open_note_id() is data._parent
				$('.add-subnote').before ich.substicky
						_id									: () -> data._id
						note_message 				: () -> data.message && data.message.replace(/(<[^>]+) style=".*?"/g, '$1')
						stacked_at_in_words	: () -> data.stacked_at && $.timeago(data.stacked_at)
						stacked_at_in_date 	: () -> format_date(data.stacked_at)

				window.dnd.draggable $("ul.timeline li[data-id=#{data._id}]")

		# increment the number porn counter on associated stacks
		socket.on 'ui:cleanup:adjust_number_porn', (parentData) ->
			self.adjust_number_porn(parentData)

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
				if self.is_note_open() and self.is_subnote() # restacking
					self.restack(this)
				else
					self.stack(this)
			return false

		li.on 'dragenter', (e) ->
			unless this is self.child or self.dropping_subnote_on_its_parent(this) 
				self.make_desirable(e, this)
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
		@cleanup_unstack(parent_id)

	#
	# Restack
	restack: (parent) ->
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')
		old_id			= @current_open_note_id()

		# Use Socket.IO to emit unstack event
		socket.emit 'notes:restack', {child_id: child_id, old_id: old_id, parent_id: parent_id}
		
		# cleanup
		@cleanup_restack(parent_id, old_id)
		
	#
	# Stack
	stack: (parent) ->
		self 				= @
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')

		unless child_id is parent_id # do not allow stacking on itself
			# Use Socket.IO to emit unstack event
			socket.emit 'notes:stack', {child_id: child_id, parent_id: parent_id}
			
			# cleanup
			if @current_open_note_id() is parent_id # if we dragging onto a note thats open
				@merge_onto_open_note(parent)
			else
				@cleanup_fresh_stack(parent)
			
			@make_fresh_stack(parent)

	#
	# Adjust the number of subnotes in a specific stack
	adjust_number_porn: (parentData) ->
		parent_id = parentData._id
		count 		= parentData._notes.length
		card 			= $("li[data-id=#{parent_id}]")

		# populate the view with the new stack actions
		$(".sticky-actions-wrapper", card).html ich.sticky_actions 
			draggable 		: false
			has_subnotes 	: true
			subnote_count : () -> if count <= 0 then '' else count 
			_id						: parent_id

	#
	# UI Cleanup duty
	make_desirable: (e, parent) ->
		$(parent).addClass('stack')
		e.originalEvent.dataTransfer.dropEffect = 'copy'

	make_undesirable: (e, parent) ->
		$(parent).removeClass('stack')

	merge_onto_open_note: (parent) ->
		parent_id = $(parent).attr('data-id')
		$('ul.timeline li.empty').remove()

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

		current_count = parseInt($("a.number-porn", card).text()) || 0
		
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
		parent.removeClass('stacked')
		$(".sticky-actions", parent).remove()

	# when we've unstacked a note, we want to decrement the count
	# from the parent note in the list
	cleanup_unstack: (parent_id) ->
		# clean up UI
		child_id 	= $(@child).attr('data-id')

		$('body').removeClass('drop')
		$("li[data-id=#{child_id}]").remove()

		# Make stacked
		card 					= $("li[data-id=#{parent_id}]")
		current_count = parseInt($("a.number-porn", card).text()) || 0


	# when we've unstacked a note, we want to decrement the count
	# from the parent note in the list
	cleanup_restack: (parent_id, old_id) ->
		# clean up UI
		card			= $("li[data-id=#{parent_id}]")
		old_card	= $("li[data-id=#{old_id}]")
		child_id 	= $(@child).attr('data-id')

		$("li[data-id=#{child_id}]").remove()
		card.removeClass('stack')

		# Make stacked		
		current_count = parseInt($("a.number-porn", card).text()) || 0
		old_count 		= parseInt($("a.number-porn", old_card).text()) || 0

