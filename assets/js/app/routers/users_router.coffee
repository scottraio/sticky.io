class App.Routers.UsersRouter extends Backbone.Router
	
	routes:
		"users"						: "index"
		"welcome" 					: "welcome"
		"users/:id" 				: "show"
		"users/:id/edit" 			: "edit"
		"users/:id/details" 		: "details"
		"users/:id/connect_with" 	: "connect_with"
		"users/:id/change_password" : "change_password"
		
	
	index: ->
		render_with_facebox () ->
			# nothing here yet
	
	show: (id) ->
		render "#stage", () ->
			new App.Views.Users.Show(user_id: id, type: "week", el: $("#content"))		
	
	edit: (id) ->
		render_with_facebox () ->
			new App.Views.Users.Edit(user_id: id, el: $("#content"))
			
	welcome: ->
		render_with_facebox() ->
			new App.Views.Users.Welcome(el: $("#content"))
		
	details: ->
		render_with_facebox () ->
			new App.Views.Users.Details(el: $("#facebox .content"))

	connect_with: ->
		render_with_facebox () ->
			new App.Views.Users.ConnectWith(el: $("#facebox .content"))
			
	change_password: ->
		render_with_facebox () ->
			# nothing