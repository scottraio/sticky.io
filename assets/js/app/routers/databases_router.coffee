class App.Routers.DatabasesRouter extends Backbone.Router
	
	routes:
		"databases"				: "index"
		"databases/new"			: "new"
		"databases/:id"			: "show"
		"databases/:id/edit" 	: "edit"
	
	index: ->
		list_db = new App.Views.Databases.Index(el: $("#stage"))
		list_db.render()
	
	new: ->
		new_db = new App.Views.Databases.New(el: $("#stage"))
		new_db.render()
	
	show: ->
		show_db = new App.Views.Databases.Show(el: $("#stage"))
		show_db.render()
		
	edit: (book_id) ->
		render '#stage', () ->
			new App.Views.Databases.New(el: $("#facebox .content"))