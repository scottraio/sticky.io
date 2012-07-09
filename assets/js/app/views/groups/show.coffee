App.Views.Groups or= {}

class App.Views.Groups.Show extends Backbone.View
		
	
	initialize: ->
		@group 		= new App.Models.Group(id: @options.id)
		@group.url 	= "/notebooks/#{@options.id}/notes.json"

	render: () ->

		@group.fetch
			success: (col, groupJSON) ->
				if groupJSON 
					notes_view = new App.Views.Notes.Index()
					notes_view.load_view(groupJSON.notes)
				else
					# add the sidebar
					#$("ul.notes_board").prepend ich.sidebar()	
					