class App.Routers.NotesRouter extends Backbone.Router
	
	routes:
		""					: "index"
		"notes"				: "index"
		"notes/list"		: "list"
		"notes/new"			: "new"
		"notes/:id"			: "show"
		"notes/:id/edit" 	: "edit"
	
	index: ->
		if current_user
			notes = new App.Views.Notes.Index(el: $("#main"))
			reset_events(notes)
			notes.render()

	list: ->
		notes = new App.Views.Notes.Index(el: $("#main"))
		reset_events(notes)
		notes.render('list')
		
	new: ->
		notes = new App.Views.Notes.New(el: $("#post_new_message"))
		reset_events(notes)
		notes.render()

	show: (id) ->
		note = new App.Views.Notes.Show(id: id, el: $('#note_details_card'))
		reset_events(note)
		note.render()

	bookmarks: () ->
		note = new App.Views.Notes.Bookmarks(el: $('#main'))
		reset_events(note)
		note.render()
	