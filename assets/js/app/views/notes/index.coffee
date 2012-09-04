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

	render: (items) ->
		self = @
		@notes.fetch
			success: (col, notes) ->
				self.notes = notes
				self.load_view()
				$(".crumb-bar").html("<a href=\"/notes\" class=\"navigate headline\">Home</a>")

	load_view: () ->
		self = @ 

		@ui_before_hook()

		# setup the notes_board
		$(@el).html ich.notes_board
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
		
		# Drag and Drop everything
		dnd = new App.Views.Notes.DnD(id: @options.id)		

		@ui_after_hook()

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
		self = @
	
		for note in @notes
			note.message = note.message.replace(/\n/g, '<br />')
			self.format_domain(note)
			for subnote in note._notes
				self.format_domain(subnote)
	
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
			$('.date-picker').DatePickerClear()
			$('.tag-label').html(@params.tags)
		else
			$('.tag-label').html('Tag')
		
		# resolve any images
		@auto_image_resolution(@notes)

	format_domain: (note) ->
		if note._domains
			for domain in note._domains
				hostname 			= domain.url.toLocation().hostname
				note.message 	= note.message.replace domain.url, "<a href='#{domain.url}' target='_blank'><img src='http://www.google.com/s2/u/0/favicons?domain=#{hostname}' /> #{domain.title}</a>"
	
	format_date: (date) ->
		date = new Date(date)
		return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear()
