App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events:
		'click .delete' : 'delete'
		'click .tag'	: 'search'
	
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

		
	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href') + ".json"
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false