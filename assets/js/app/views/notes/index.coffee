App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	
	
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
				self.auto_everything()

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

	auto_everything: () ->
		$('.autotag').autotag()
		$('.autolink').autolink()
		
 		
