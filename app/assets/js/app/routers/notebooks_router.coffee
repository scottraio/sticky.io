class App.Routers.NotebooksRouter extends Backbone.Router
	
	routes:
		"notebooks/new"													: "new"
		"notebooks/:id/edit" 										: "edit"
	
	new: () ->
		notebook = new App.Views.Notebooks.New(el: $('#notebook'))
		reset_events notebook
		notebook.render()

	edit: (id) ->
		notebook = new App.Views.Notebooks.Edit(el: $('#notebook'), id: id)
		notebook.render()

