App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events:
		'click .card'	: 'show_note_details'
	
	initialize: ->
		@url = '/notes.json'

	render: (notes) ->
		self = @
		$.getJSON @url, (items) ->
			self.render_view(items)	

	render_view: (items) ->
		$('#stage').html ich.notes_list
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)

		$(@el).autolink()
		$(@el).autotag()

	show_note_details: (e) ->
		id = $(e.currentTarget).attr('data-id')
		navigate "/notes/#{id}"
		
