class App.Routers.NotesRouter extends Backbone.Router
	
	routes:
		""								: "index"
		"notes"						: "index"
		"notes/new"				: "new"
		"notes/:id/new"		: "new"
		"notes/:id"				: "show"
		"notes/:id/edit" 	: "edit"
	
	index: (params) ->
		if current_user
			notes = new App.Views.Notes.Index(el: $("#stage"), params: params)
			reset_events(notes)
			notes.render()
		
	new: (id) ->
		notes = new App.Views.Notes.New(el: $("#post_new_message"), id: id)
		reset_events(notes)
		notes.render()

	show: (id) ->
		note = new App.Views.Notes.Show(id: id, el: $("#expanded-view"))
		reset_events(note)
		note.render()

	edit: (id) ->
		note = new App.Views.Notes.Edit(id: id, el: $("li.sticky[data-id=#{id}]"))
		note.render()
