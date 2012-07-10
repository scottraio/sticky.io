App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events: 
		'dblclick .sticky' 						: 'edit'
		'click .delete'  						: 'delete'
		'click .dropdown-menu .color-choice'  	: 'update_color'
	
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

	load_view: (items) ->
		self = @ 

		# setup the notes_board
		$('#stage').html ich.notes_board
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)
			has_subnotes: () -> true if this._notes && this._notes.length > 0
			subnote_count: () -> this._notes.length

		dnd = new App.Views.Notes.DnD(@options)		
		dnd.acts_as_draggable $('#stage ul.notes_board li')
		dnd.acts_as_droppable $('#stage ul.notes_board li')
		dnd.acts_as_draggable $('#stage ul.notes_board li .subnote')
		# make the stage droppable for subnotes
		dnd.droppable_body $('body')

		# autolink everything
		$('.autolink').autolink()

		# resolve any images
		@auto_image_resolution(items)

		

	
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

				console.log meta
				console.log color_box
			error: (data, res) ->
				console.log 'error'

	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()


		
