App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events: 
		'click .card-info' : 'navigate'
	
	initialize: ->
		@notes 		= new App.Collections.Notes()
		@filters  	= @options.tags

	render: (type) ->
		self = @
		@notes.fetch 
			success: (col, items) ->
				if type is 'list'
					self.render_list(items)
				else
					self.render_board(items)	

				$('.autolink').autolink()

				self.auto_image_resolution(items)

				

	render_list: (items) ->
		self = @
		$('#stage').html ich.notes_list
			filters: self.filters || "All"
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)
		
	render_board: (items) ->
		$('#stage').html ich.notes_board
			filters: self.filters || "All"
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)
		
	show_note_details: (e) ->
		id = $(e.currentTarget).attr('data-id')
		navigate "/notes/#{id}"

	navigate: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false


	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_image_links()

		
 		
