window.App =
	Models: {}
	Collections: {}
	Controllers: {}
	Routers: {}
	Views: {}
	acts_as_facebox: false
	desktop_client: (client) ->
		if client
			@desktop_client = client
		else
			return @desktop_client
			
	environment: (env) ->
		if env
			@env = env
		else
			return @env
	current_user: (user) ->
		if user
			@user = new App.Models.User(user)
		else
			return @user
	start: (mode) ->
		window.xhr = mode
		new App.Routers.NotesRouter()
		new App.Routers.UsersRouter()
		Backbone.history.start {pushState:true}