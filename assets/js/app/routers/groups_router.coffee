class App.Routers.GroupsRouter extends Backbone.Router
	
	routes:
		"notebooks"				: "index"
		"notebooks/new"			: "new"
		"notebooks/:id"			: "show"
		"notebooks/:id/edit" 	: "edit"

	index: ->
		group = new App.Views.Groups.Index(el: $("#stage"))
		group.render()

	new: ->
		group = new App.Views.Groups.New(el: $("#group_modal"))
		group.render()

	show: (id) ->
		group = new App.Views.Groups.Show(id: id, el: $('#stage'))
		reset_events(group)
		group.render()

	edit: (id) ->
		group = new App.Views.Groups.Edit(id: id, el: $('#group_modal'))
		group.render()