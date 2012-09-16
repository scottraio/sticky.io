App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View

	events:
		'click .delete'  						            : 'delete'
		'click .dropdown-menu .color-choice'  	: 'update_color'
		'click .task-completed'					        : 'mark_completed'
	
	initialize: ->
		@params		= @options.params
		@notes 		= new App.Collections.Notes()
		# set the url to the search query, if there is a search query
		if window.location.search
			@notes.url 	= window.location.pathname + ".json" + window.location.search

	render: () ->
		self = @
		@notes.fetch
			success: (col, notes) ->
				self.notes = notes
				self.ui_before_hook()
				self.load_view()
				self.ui_after_hook()

	load_view: () ->
		self = @

		# setup the notes_board
		notes_html =  ich.notes_board
			notes								: @notes
			note_message				: () -> escape(this.message)
			created_at_in_words	: () -> this.created_at && $.timeago(this.created_at)
			created_at_in_date 	: () -> self.format_date(this.created_at)
			has_subnotes				: () -> true if this._notes && this._notes.length > 0
			draggable						: () -> true unless this._notes && this._notes.length > 0
			subnote_count				: () -> this._notes.length if this._notes
			is_taskable					: () -> true if this.message && this.message.indexOf('#todo') > 0
			has_domains					: () -> true if this._domains && this._domains.length > 0
			domain							: () -> this.url.toLocation().hostname if this.url
			more_link						: () -> window.location.pathname
	
		if @params && @params.page
			$(@el).append notes_html
		else
			$(@el).html notes_html			

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
				if is_complete
					$(e.currentTarget).parents('.message').addClass('completed')
				else
					$(e.currentTarget).parents('.message').removeClass('completed')
				
			error: (data, res) ->
				console.log 'error'

	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()

	ui_before_hook: ->
		self 				= @

		# Do some post-processing work and format the notes i.e. displaying titles for domains
		collection 	= new App.Collections.Notes()
		collection.format_domains(@notes)
	
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
		
		if @params && @params.tags
			$('.tag-button').addClass('btn-primary')
			$('.tag-label').html(@params.tags)
		else
			$('.tag-button').removeClass('btn-primary')
			$('.tag-label').html('None')
		
		# Drag and Drop
		window.dnd = new App.Views.Notes.DnD(id: @options.id)
		window.dnd.acts_as_draggable $('ul.notes_board li:not(.stacked)', @el)
		window.dnd.acts_as_droppable $('ul.notes_board li', @el)
	
		# make the inbox scroll to infinity
		@infinite_scroll()
			
		# resolve any images
		@auto_image_resolution(@notes)

	format_date: (date) ->
		date = new Date(date)
		return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear()

	infinite_scroll: () ->
		self = @
		$('#stage').scroll () ->
			# We check if we're at the bottom of the scrollcontainer
			if (self.notes.length > 0 and self.notes.length <= 25) && ($(this)[0].scrollHeight - $(this).scrollTop() == $(this).outerHeight())
				# If we're at the bottom, show the overlay and retrieve the next page
				window.current_page += 1
				navigate '/notes' + add_or_replace_query_var(document.location.search, 'page', window.current_page)
				
