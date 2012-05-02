class App.Routers.RecordsRouter extends Backbone.Router
	
	routes:
		":database_id/:table_id/records" 			: "index"
		":database_id/:table_id/records/new"		: "new"
		":database_id/:table_id/records/:id"		: "show"
		":database_id/:table_id/records/:id/edit" 	: "edit"
	
	index: (database_id, table_id) ->
		list_tables = new App.Views.Records.Index(el: $("#stage"), database_id: database_id, table_id: table_id)
		list_tables.render()
	
	new: (database_id, table_id) ->
		new_table = new App.Views.Records.New(el: $("#stage"), database_id: database_id, table_id: table_id)
		new_table.render()
	
	show: (database_id, table_id, id) ->
		show_table = new App.Views.Records.Show(el: $("#stage"), database_id: database_id, table_id:table_id, id: id)
		show_table.render()
		
	edit: (book_id) ->
		# do something