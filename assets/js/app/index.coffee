window.App =
	Models: {}
	Collections: {}
	Controllers: {}
	Routers: {}
	Views: {}
	start: (current_user) ->
		window.current_user = current_user
		new App.Routers.NotesRouter()
		new App.Routers.UsersRouter()
		Backbone.history.start {pushState:true}