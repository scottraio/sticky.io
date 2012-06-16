class App.Routers.NotesRouter extends Backbone.Router
	
	routes:
		""					: "index"
		"notes"				: "index"
		"notes/new"			: "new"
		"notes/:id"			: "show"
		"notes/:id/edit" 	: "edit"
	
	index: (params) ->
		if current_user
			params or= {}
			notes 	= new App.Views.Notes.Index(el: $("#main"))
			
			reset_events(notes)
			notes.render(params.view||'board')
		
	new: ->
		notes = new App.Views.Notes.New(el: $("#post_new_message"))
		reset_events(notes)
		notes.render()

	show: (id) ->
		note = new App.Views.Notes.Show(id: id, el: $('#note_details_card'))
		reset_events(note)
		note.render()

	edit: (id) ->
		note = new App.Views.Notes.Edit(id: id, el: $('#note_details_card'))
		reset_events(note)
		note.render()