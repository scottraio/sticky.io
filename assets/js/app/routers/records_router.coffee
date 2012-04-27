class App.Routers.RecordsRouter extends Backbone.Router
	
	routes:
		"records/:id"							: "show"
		"reports/:report_id/records/:id"		: "show"
		"records/:id/edit"						: "edit"
		"records/:id/email"						: "email"
		"records/:id/pin"						: "pin"
	
	show: (id) ->
		render "#stage", () ->
			record 		= new App.Views.Records.Show(record_id: id, el: $(".page"))
			comments 	= new App.Views.Records.Comments( el: $("#record-comments") )
			

	edit: (id) -> 
		render "#stage", () ->
			new App.Views.Records.Edit(record_id: id, el: $(".page"))

	email: (id) ->
		render_with_facebox () ->
			# do something

	pin: (id) ->
		render_with_facebox () ->
			# do something