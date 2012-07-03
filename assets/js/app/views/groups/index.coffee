App.Views.Groups or= {}

class App.Views.Groups.Index extends Backbone.View
		
	
	initialize: ->
		@groups 	= new App.Collections.Groups()

	render: () ->
		self = @
		# load notebooks
		@groups.fetch
			success: (col, items) ->
				$('ul.notes_board').prepend ich.groups_board
						stacks: items

				$('ul.notes_board li.deck').each (i, notebook) ->
					self.acts_as_droppable(notebook)

	acts_as_droppable: (li) ->
		li.addEventListener 'drop', (e) ->
			# this / e.target is current target element.
			if e.stopPropagation
				e.stopPropagation() # stops the browser from redirecting.
			
			# source 
			source_id = e.dataTransfer.getData('Text')
			$("li[data-id=#{source_id}]").remove()

			# target
			unless $(this).attr('data-id') is source_id
				$(this).addClass('deck')
				$(this).removeClass('stack')

			return false
		, false

		li.addEventListener 'dragenter', (e) ->
			$(this).addClass('stack')
			return false
		, false

		li.addEventListener 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			e.dataTransfer.dropEffect = 'copy';
			$(this).addClass('stack')
		, false

		li.addEventListener 'dragleave', (e) ->
			$(this).removeClass('stack') # this / e.target is previous target element.
		, false