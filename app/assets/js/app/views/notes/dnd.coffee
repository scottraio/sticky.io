App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View


	bind: (options) ->
		#@reset()

		if options && options.id
			$('body').attr('data-current-note-open', options.id) 
			@droppable $('#expanded-view')
			@draggable $('#expanded-view ul.timeline li')
		else
			@draggable $('ul.notes_board li:not(.stacked)')
			@droppable $('ul.notes_board li')

	reload: () ->
		push_url window.location.pathname + "?" + window.location.search
		#if @is_note_open()
			#push_url("/notes/#{@current_note_id}")

	is_note_open: () ->
		# return true if we've expanded a note into the expanded view
		true if @current_open_note_id() && @current_open_note_id().length > 0

	is_subnote: () ->
		$(@srcElement).hasClass("subnote")

	current_open_note_id: () ->
		$('body').attr('data-current-note-open')



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
			unless this is self.child
				if self.is_note_open() and $(@child).hasClass("subnote") # restacking
					self.restack(this)
				else
					self.stack(this)
			return false

		li.on 'dragenter', (e) ->
			unless this is self.draggable
				$(this).addClass('stack')
			return false

		li.on 'dragover', (e) ->
			e.preventDefault() if e.preventDefault # Necessary. Allows us to drop.
			# source 
			unless this is self.child
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

	unstack: (body) ->
		self 				= @
		child_id 		= $(@child).attr('data-id')
		parent_id 	= @current_open_note_id()

		$.getJSON "/notes/#{child_id}/unstack/#{parent_id}.json", (res) ->
			$(body).removeClass('drop')
			$("li[data-id=#{child_id}]").remove()

			self.reload()

	restack: (parent) ->
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')
		old_id			= @current_open_note_id()

		$.getJSON "/notes/#{child_id}/restack/#{old_id}/#{parent_id}.json", (res) ->
			$("li[data-id=#{child_id}]").remove()
			$(parent).removeClass('stack')

	stack: (parent) ->
		console.log @
		self 				= @
		child_id 		= $(@child).attr('data-id')
		parent_id 	= $(parent).attr('data-id')

		$.getJSON "/notes/#{child_id}/stack/#{parent_id}.json", (res) ->
			# Cleanup UI
			if self.current_open_note_id() is parent_id # if we dragging onto a note thats open
				self.merge_onto_open_note(parent)
			else
				self.cleanup_fresh_stack(parent)
				self.make_fresh_stack(parent)
	

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

		# push to the new timeline - easy, simple.
		push_url '/notes/' + parent_id

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


	reset: () ->
		$("body").unbind("drop")
		$("body").unbind("dragenter")
		$("body").unbind("dragover")
		
		$('#expanded-view').unbind("drop")
		$('#expanded-view').unbind("dragenter")
		$('#expanded-view').unbind("dragover")

		$('li').unbind("drop")
		$('li').unbind("dragenter")
		$('li').unbind("dragover")
