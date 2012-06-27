App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events: 
		'dblclick .sticky' 	: 'edit'
		'click .delete'  	: 'delete'
	
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
		$('#stage').html ich.notes_board
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)

		# autolink everything
		$('.autolink').autolink()

		# add the sidebar
		$("ul.notes_board").prepend ich.sidebar()		

		# make it sortable
		$("ul.notes_board").sortable
			items: "li.sticky"
		
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


	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()

		
 		
