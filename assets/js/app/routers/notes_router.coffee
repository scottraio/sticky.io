class App.Routers.NotesRouter extends Backbone.Router
	
	routes:
		""					: "index"
		"notes"				: "index"
		"notes/new"			: "new"
		"notes/:id"			: "show"
		"notes/:id/edit" 	: "edit"
	
	index: ->
		if current_user
			notes = new App.Views.Notes.Index(el: $("#main"))
			notes.render()
		
	new: ->
		notes = new App.Views.Notes.New(el: $("#post_new_message"))
		notes.render()

	show: (id) ->
		note = new App.Views.Notes.Show(id: id, el: $('#note_details_card'))
		note.render()

	bookmarks: () ->
		note = new App.Views.Notes.Bookmarks(el: $('#main'))
		note.render()		
	