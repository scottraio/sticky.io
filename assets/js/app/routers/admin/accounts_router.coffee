App.Routers.Admin or= {}

class App.Routers.Admin.AccountsRouter extends Backbone.Router
	
	routes:
		"admin/accounts" 		: "index"
		"admin/accounts/:id" 	: "show"

	index: () ->
		render "#stage", () ->
			new App.Views.Admin.Accounts.Index(el: $(".page"))
			
	show: () ->
		render "#stage", () ->
			# nothing here yet