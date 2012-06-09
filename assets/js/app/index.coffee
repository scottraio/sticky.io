window.App.start = (current_user) ->
	window.current_user = current_user
	new App.Routers.NotesRouter()
	new App.Routers.UsersRouter()
	new App.Routers.BookmarksRouter()
	Backbone.history.start {pushState:true}