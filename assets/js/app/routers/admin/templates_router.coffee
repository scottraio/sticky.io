App.Routers.Admin or= {}

class App.Routers.Admin.TemplatesRouter extends Backbone.Router
	
	routes:
		"admin/templates" 		: "index"
		"admin/templates/:id" 	: "show"

	index: () ->
		render "#stage", () ->
			# nothing here yet
			
	show: () ->
		render "#stage", () ->
			# nothing here yet