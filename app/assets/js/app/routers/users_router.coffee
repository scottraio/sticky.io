class App.Routers.UsersRouter extends Backbone.Router
	
	routes:
		"settings" 							: "edit"
		"welcome" 							: "welcome"
		"confirm_phone_number" 	: "confirm_phone_number"
		
	edit: () ->
		edit = new App.Views.Users.Edit(el: $('#settings'), id: current_user._id)
		edit.render()

	welcome: () ->
		view = new App.Views.Users.Welcome(el: $('.welcome'))
		view.render()

	confirm_phone_number: () ->
		number = new App.Views.Users.ConfirmPhoneNumber(el: $('#confirm_phone_number'))
		number.render()

