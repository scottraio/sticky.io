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

		
	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href')
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false