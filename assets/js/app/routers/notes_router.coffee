class App.Routers.NotesRouter extends Backbone.Router
	
	routes:
		""				: "index"
		"notes"				: "index"
		"notes/new"			: "new"
		"notes/:id"			: "show"
		"notes/:id/edit" 	: "edit"
	
	index: ->
		notes = new App.Views.Notes.Index(el: $("#stage"))
		notes.render()
		
	