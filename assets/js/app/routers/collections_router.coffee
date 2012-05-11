class App.Routers.CollectionsRouter extends Backbone.Router
	
	routes:
		":database_id/collections"			: "index"
		":database_id/collections/new"		: "new"
		":database_id/collections/:id"		: "show"
		":database_id/collections/:id/edit" : "edit"
	
	index: (database_id) ->
		list_collections = new App.Views.Collections.Index(el: $("#stage"), database_id: database_id)
		list_collections.render()
	
	new: (database_id) ->
		new_collection = new App.Views.Collections.New(el: $("#stage"), database_id: database_id)
		new_collection.render()
	
	show: (database_id, id) ->
		show_collection = new App.Views.Collections.Show(el: $("#stage"), database_id: database_id, id: id)
		show_collection.render()
		
	edit: (book_id) ->
		# do something