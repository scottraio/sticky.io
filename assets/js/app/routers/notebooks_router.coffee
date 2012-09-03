class App.Routers.NotebooksRouter extends Backbone.Router
	
	routes:
		"notebooks/new"													: "new"
		"notebooks/:id/edit" 										: "edit"
		"notebooks/:id/members/:user_id/remove" : "remove_member"
	
	new: () ->
		notebook = new App.Views.Notebooks.New(el: $('#add-notebook'))
		notebook.render()

	edit: (id) ->
		notebook = new App.Views.Notebooks.Edit(el: $('#edit-notebook'), id: id)
		notebook.render()

	remove_member: (id, user_id) ->
		console.log 'test'
		$.getJSON "/notebooks/#{id}/members/#{user_id}/remove.json", (res) ->
			return false
