class App.Routers.NotebooksRouter extends Backbone.Router
	
	routes:
		"notebooks/new"				: "new"
		"notebooks/:id/edit" 	: "edit"
	
	new: () ->
		notebook = new App.Views.Notebooks.New(el: $('#add-notebook'))
		notebook.render()

	edit: (id) ->
		notebook = new App.Views.Notebooks.Edit(el: $('#edit-notebook'), id: id)
		notebook.render()
