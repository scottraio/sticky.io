App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events:
		'click .tag'	: 'search'
		'click .card'	: 'show_note_details'
	
	initialize: ->
		@url = '/notes.json'

	render: ->
		self = @
	
		$.getJSON @url, (items) ->
			self.render_view(items)	

	search: (e) ->
		self = @

		$.post '/notes/filter.json', {tags: [$(e.currentTarget).attr('data-tag-name')]}, (items) ->
			self.render_view(items)	
		return false

	render_view: (items) ->
		$('#stage').html ich.notes_list
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)

		$(@el).autolink()
		$(@el).autotag()

		tag_list = new App.Views.Tags.Index()
		tag_list.render()

	show_note_details: (e) ->
		id = $(e.currentTarget).attr('data-id')
		navigate "/notes/#{id}"
		
