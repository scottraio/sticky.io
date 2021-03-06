App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View

	events:
		'click .delete'  						            : 'delete'
		'click .dropdown-menu .color-choice'  	: 'update_color'
		'click ul.notes_board li'								: 'link_to_note'
		'click .task-completed'					        : 'mark_completed'
		'mouseover .drag-handle'								: 'make_draggable'
		'mouseout .drag-handle'									: 'make_undraggable'
	
	initialize: ->
		@params						= @options.params
		@notes_collection = new App.Collections.Notes()

		# set the url to the search query, if there is a search query
		if window.location.search
			@notes_collection.url 	= window.location.pathname + ".json" + window.location.search
		else
			$("ul.sidebar-nav li").removeClass('selected')

		# make the inbox scroll to infinity
		@scroll = new App.Views.Notes.Scroll()
		@scroll.bind(@)

	render: (append) ->
		self 					= @
		@scroll.lock 	= true # lock the scroll event until we're finished loading results

		@notes_collection.fetch
			success: (col, notes) ->
				return if notes.length <= 0 && self.current_page > 0 
				# if we're paginating and there are no more notes, lets assume we're at the 
				# end of the list
				self.notes = notes

				# Before hook
				self.ui_before_hook()

				#
				# Load the view accordingly
				if append
					$(self.el).append(self.ich_notes())
				else
					$(self.el).html(self.ich_notes())

				# After hook
				self.ui_after_hook()

	ich_notes: () ->
		# setup the notes_board
		TEMPLATES['inbox'] {notes:@notes}

	load_page: (page) ->
		@current_page = page
		@notes_collection.url = '/notes.json' + add_or_replace_query_var(document.location.search, 'page', page)
		@render(true)
			
	show: (e) ->
		id = $(e.currentTarget).attr('data-id')
		push_url "/notes/#{id}"
		return false

	delete: (e) ->
		self = @
		sticky = $(e.currentTarget).parent('.sticky')
		note = new App.Models.Note(id: sticky.attr('data-id'))
		note.destroy
			success: (model, res) ->
				$(sticky).remove()
		return false

	link_to_note: (e) ->
		if e.target.tagName is 'DIV'
			push_url '/notes/' + $(e.currentTarget).attr('data-id')
			#$('#expanded-view').css('padding-top', $(e.currentTarget).offset().top - 132)
			return false

	update_color: (e) ->
		color 	= $(e.currentTarget).attr('data-color')
		note 	= new App.Models.Note(id: $(e.currentTarget).parents('.sticky').attr('data-id'))

		save note, {color: color}
			success: (data, res) ->
				meta = $(e.currentTarget).parents('div.meta')
				meta.removeClass()
				meta.addClass('meta')
				meta.addClass(color)

				color_box = meta.children('.color-choice:first')
				color_box.removeClass()
				color_box.addClass('color-choice')
				color_box.addClass(color)
			error: (data, res) ->
				console.log 'error'

	mark_completed: (e) ->
		$sticky			= $( $(e.currentTarget).parents('[data-id]')[0] )
		note_id 		= $sticky.attr('data-id')
		note 				= new App.Models.Note(id: note_id)
		is_complete = $(e.currentTarget).is(":checked")

		save note, {completed: is_complete}
			success: (data, res) ->
				if data.attributes.completed
					$(e.target).parents('.message_wrapper').addClass('completed')
				else
					$(e.target).parents('.message_wrapper').removeClass('completed')
				
			error: (data, res) ->
				console.log 'error'

	ui_before_hook: ->
		self 				= @

		# Do some post-processing work and format the notes i.e. displaying titles for domains
		@notes_collection.parse_for_view(@notes)
	
	ui_after_hook: ->
		unless @params
			today					= new Date()
			threedaysago 	= new Date(new Date().setDate(today.getDate() - 3))

			$('.date-picker').DatePickerSetDate([threedaysago, today])

		# Build the rest of the UI accordingly
		#$('.remove-stray-links').remove_stray_links()
		
		# auto-link everything
		$('.message').autolink()
		
		# enable dropdowns (color)
		$('.dropdown-toggle').dropdown()
		
		# select the appropiate UI controls
		@select_ui_controls()
		
		# drag and drop
		window.dnd.draggable $('ul.notes_board li:not(.stacked)')
		window.dnd.droppable $('ul.notes_board li')
			
		@scroll.lock = false

	select_ui_controls: () ->
		if @params && @params.tags
			$('.tag-button').addClass('btn-primary')
			$('.tag-label').html(@params.tags)
		else
			$('.tag-button').removeClass('btn-primary')
			$('.tag-label').html('None')

		if @params && @params.notebooks
			# reset the notebook nav
			$("ul.sidebar-nav li").removeClass('selected')
			$("a[data-param-val=#{@params.notebooks}]").parents('li').addClass('selected')

		if @params && @params.order
			$('.inbox-controls a.query').removeClass('active')
			$("a[data-param-val=#{@params.order}]").addClass('active')

	notebook_color: (notebook) ->
		try 
			$("li[data-name=#{notebook['.']}]").attr('data-color') 
		catch error
			''
	make_draggable: (e) ->
		$(e.currentTarget).parents('li').attr('draggable', true)
		return false

	make_undraggable: (e) ->
		$(e.currentTarget).parents('li').attr('draggable', false)
		return false

	
