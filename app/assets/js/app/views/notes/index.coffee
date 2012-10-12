App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View

	events:
		'click .delete'  						            : 'delete'
		'click .dropdown-menu .color-choice'  	: 'update_color'
		'click ul.notes_board li'								: 'link_to_note'
		'click .task-completed'					        : 'mark_completed'
	
	initialize: ->
		@params		= @options.params
		@notes 		= new App.Collections.Notes()
		# set the url to the search query, if there is a search query
		if window.location.search
			@notes.url 	= window.location.pathname + ".json" + window.location.search
		else
			$("ul.sidebar-nav li").removeClass('selected')

	render: () ->
		self = @
		@notes.fetch
			success: (col, notes) ->
				self.notes = notes

				# Before hook
				self.ui_before_hook()

				#
				# Load the view accordingly
				if self.params && self.params.page
					$(self.el).append(self.ich_notes())
				else
					$(self.el).html(self.ich_notes())

				# After hook
				self.ui_after_hook()

	ich_notes: () ->
		self = @

		# setup the notes_board
		notes_html =  ich.notes_board
			notes								: @notes
			note_message				: () -> this.message.replace(/(<[^>]+) style=".*?"/g, '$1')
			created_at_in_words	: () -> this.created_at && $.timeago(this.created_at)
			created_at_in_date 	: () -> self.format_date(this.created_at)
			has_subnotes				: () -> true if this._notes && this._notes.length > 0
			draggable						: () -> true unless this._notes && this._notes.length > 0
			subnote_count				: () -> this._notes.length if this._notes
			is_taskable					: () -> true if this.message && this.message.indexOf('#todo') > 0
			has_domains					: () -> true if this._domains && this._domains.length > 0
			domain							: () -> this.url.toLocation().hostname if this.url
			group_colors				: () -> self.group_colors(this)
			
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
		
		# select the appropiate UI controls
		@select_ui_controls()
		
		# drag and drop
		window.dnd.draggable $('ul.notes_board li:not(.stacked)')
		window.dnd.droppable $('ul.notes_board li')
	
		# make the inbox scroll to infinity
		@infinite_scroll()
			
		# resolve any images
		@auto_image_resolution(@notes)

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

	format_date: (date) ->
		date = new Date(date)
		return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear()

	group_colors: (note) ->
		colors = []
		if note.groups
			for group in note.groups
				colors.push $("li[data-name=#{group}]").attr('data-color')

		if colors
			return (colors + "").replace(',', ' ')

	infinite_scroll: () ->
		self = @
		$('#stage').scroll () ->
			# We check if we're at the bottom of the scrollcontainer
			if (self.notes.length > 0 and self.notes.length <= 25) && ($(this)[0].scrollHeight - $(this).scrollTop() == $(this).outerHeight())
				# If we're at the bottom, show the overlay and retrieve the next page
				window.current_page += 1
				navigate '/notes' + add_or_replace_query_var(document.location.search, 'page', window.current_page)
				
