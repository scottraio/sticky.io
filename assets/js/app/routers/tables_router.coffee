class App.Routers.TablesRouter extends Backbone.Router
	
	routes:
		":database_id/tables"			: "index"
		":database_id/tables/new"		: "new"
		":database_id/tables/:id"		: "show"
		":database_id/tables/:id/edit" 	: "edit"
	
	index: (database_id) ->
		list_tables = new App.Views.Tables.Index(el: $("#stage"), database_id: database_id)
		list_tables.render()
	
	new: (database_id) ->
		new_table = new App.Views.Tables.New(el: $("#stage"), database_id: database_id)
		new_table.render()
	
	show: (database_id, id) ->
		show_table = new App.Views.Tables.Show(el: $("#stage"), database_id: database_id, id: id)
		show_table.render()
		
	edit: (book_id) ->
		# do something