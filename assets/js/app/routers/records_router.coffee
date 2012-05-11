class App.Routers.RecordsRouter extends Backbone.Router
	
	routes:
		":database_id/:collection_id/records" 			: "index"
		":database_id/:collection_id/records/new"		: "new"
		":database_id/:collection_id/records/:id"		: "show"
		":database_id/:collection_id/records/:id/edit" 	: "edit"
	
	index: (database_id, collection_id) ->
		list_collections = new App.Views.Records.Index(el: $("#stage"), database_id: database_id, collection_id: collection_id)
		list_collections.render()
	
	new: (database_id, collection_id) ->
		new_collection = new App.Views.Records.New(el: $("#stage"), database_id: database_id, collection_id: collection_id)
		new_collection.render()
	
	show: (database_id, collection_id, id) ->
		show_collection = new App.Views.Records.Show(el: $("#stage"), database_id: database_id, collection_id:collection_id, id: id)
		show_collection.render()
		
	edit: (book_id) ->
		# do something