class App.Routers.UsersRouter extends Backbone.Router
	
	routes:
		"settings" 	: "edit"
		"welcome" 	: "welcome"
		
	edit: () ->
		edit = new App.Views.Users.Edit(el: $('#settings'), id: current_user._id)
		edit.render()

	welcome: () ->
		view = new App.Views.Users.Welcome(el: $('#welcome'))
		view.render()
