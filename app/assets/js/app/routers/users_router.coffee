class App.Routers.UsersRouter extends Backbone.Router
	
	routes:
		"settings" 	: "edit"
		"welcome" 	: "welcome"
		
	edit: (id) ->
		edit = new App.Views.Users.Edit()
		edit.render()

	welcome: () ->
		view = new App.Views.Users.Welcome(el: $('#welcome'))
		view.render()
