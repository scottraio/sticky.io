App.Views.Notes or= {}

class App.Views.Notes.DnD extends Backbone.View

	reload: () ->
		push_url window.location.pathname + "?" + window.location.search

	#
	# Drag and Drop
	#

	droppable_body: (body) ->
		self = @

		body.on 'drop', (e) ->
			e.stopPropagation() if e.stopPropagation # stops the browser from redirecting.
		
			note 		= $(self.srcElement)
			note_id		= note.attr('data-id')
			parent_id 	= $(self.draggable).attr('data-id')

			if note.hasClass("subnote") and note_id isnt parent_id
				
				if self.options.id 
					$.getJSON "/notes/#{note_id}/rebind/#{parent_id}/#{self.options.id}.json", (res) ->
						self.reload()
				else
					$.getJSON "/notes/#{note_id}/unbind/#{parent_id}.json", (res) ->
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

			note_id 	= $(self.draggable).attr('data-id')
			parent_id 	= $(this).attr('data-id')

			# target
			unless this is self.draggable
				$.getJSON "/notes/#{note_id}/bind/#{parent_id}.json", (res) ->
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
			e.originalEvent.dataTransfer.effectAllowed = 'all'
			e.originalEvent.dataTransfer.setData('Text', $(e.currentTarget).attr('data-id')) 
			this.style.opacity = '0.4'

		li.on 'dragend', (e) ->
			this.style.opacity = '1'

		
