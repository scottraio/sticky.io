App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View

	events:
		'dblclick li.sticky' 					          : 'edit' 
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
			success: (col, items) ->
				self.load_view(items)
				$(".crumb-bar").html("<a href=\"/notes\" class=\"navigate headline\">Home</a>")

	load_view: (items) ->
		self = @ 

		# setup the notes_board
		$(@el).html ich.notes_board
			notes								: items
			created_at_in_words	: () -> $.timeago(this.created_at)
			has_subnotes				: () -> true if this._notes && this._notes.length > 0
			subnote_count				: () -> this._notes.length if this._notes
			is_taskable					: () -> true if this.message && this.message.indexOf('#todo') > 0
			has_domains					: () -> true if this._domains && this._domains.length > 0
			domain							: () -> this.url.toLocation().hostname if this.url
			
		# Drag and Drop everything
		dnd = new App.Views.Notes.DnD(id: @options.id)		

		$('.remove-stray-links').remove_stray_links()
		# auto-link everything
		$('.autolink').autolink()
		# enable dropdowns (color)
		$('.dropdown-toggle').dropdown()

		# resolve any images
		@auto_image_resolution(items)

	show: (e) ->
		id = $(e.currentTarget).attr('data-id')
		push_url "/notes/#{id}"
		return false

	edit: (e) ->
		id = $(e.currentTarget).attr('data-id')
		push_url "/notes/#{id}/edit"

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
		$sticky		= $( $(e.currentTarget).parents('[data-id]')[0] )

		note_id 	= $sticky.attr('data-id')
		note 		= new App.Models.Note(id: note_id)
		is_complete = $(e.currentTarget).is(":checked")

		save note, {completed: is_complete}
			success: (data, res) ->
				if is_complete
					$(e.currentTarget).parent('.autolink').addClass('completed')
				else
					$(e.currentTarget).parent('.autolink').removeClass('completed')
				
			error: (data, res) ->
				console.log 'error'

	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()


		
