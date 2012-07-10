App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View


	unpack_and_save: (target) ->
		self = @
		source_id 	= $(self.srcElement).attr('data-id')
		parent_id	= $(self.draggable).attr('data-id')

		@unbind_note new App.Models.Note(id: parent_id), source_id, () ->
			$(target).removeClass('drop')		
			push_url window.location.pathname + "?" + window.location.search

		@clear_path new App.Models.Note(id: source_id)
		


	assign_and_save: (target, parent_id) ->
		self = @
		source_id 	= $(@draggable).attr('data-id')

		@bind_note new App.Models.Note(id: parent_id), source_id, () ->
			$(self.draggable).remove()
			$(target).removeClass('stack')		
			push_url window.location.pathname + "?" + window.location.search
			
		@set_path new App.Models.Note(id: source_id), parent_id

	bind_note: (note, source_id, cb) ->
		save , {_notes: source_id}
			success: (data, res) -> cb()
			error: (data, res) -> console.log 'error'

	unbind_note: (note, source_id, cb) ->
		save note, {unbind: source_id}
			success: (data, res) -> cb()
			error: (data, res) -> console.log 'error'

	clear_path: (note) ->
		save note, {clear_path: true}
			success: (data, res) -> # do something
			error: (data, res) -> console.log 'error'

	set_path: (note, path) ->
		save note, {path: path}
			success: (data, res) -> # success
			error: (data, res) -> console.log 'error'


	#
	# Drag and Drop
	#

	droppable_body: (body) ->
		self = @

		body.on 'drop', (e) ->
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.
		
			if $(self.srcElement).hasClass("subnote")
				if self.options.id 
					self.assign_and_save(this, self.options.id)
				else
					self.unpack_and_save(this)
				
			return false
		

		body.on 'dragenter', (e) ->
			if $(self.srcElement).hasClass("subnote")
				$(this).addClass('drop')
				$(self.srcElement).hide()
			return false

		body.on 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			# source 
			if $(self.srcElement).hasClass("subnote")
				$(this).addClass('drop')
				e.originalEvent.dataTransfer.dropEffect = 'copy'
			
			return false	

		body.on 'dragleave', (e) ->
			$(this).removeClass('drop') # this / e.target is previous target element.

	acts_as_droppable: (li) ->
		self = @

		li.on 'drop', (e) ->
			# this / e.target is current target element.
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.

			# target
			unless this is self.draggable
				self.assign_and_save(this, $(this).attr('data-id'))
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
			this.style.opacity = '0.4'

		li.on 'dragend', (e) ->
			this.style.opacity = '1'

		
