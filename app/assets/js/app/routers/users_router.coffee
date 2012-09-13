class App.Routers.UsersRouter extends Backbone.Router
	
	routes:
		"settings" : "edit"
		
	edit: (id) ->
		edit = new App.Views.Users.Edit()
		edit.render()
