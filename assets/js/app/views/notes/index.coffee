App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events:
		'click .delete' : "delete"
	
	initialize: ->	

	render: ->
		self = @
		$.getJSON '/notes.json', (items) ->
			$(self.el).html ich.notes_list
				notes: items
				created_at_in_words: () -> $.timeago(this.created_at)

			$(self.el).autolink()
			$(self.el).autotag()

		
	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href') + ".json"
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false