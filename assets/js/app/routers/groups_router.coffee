class App.Routers.GroupsRouter extends Backbone.Router
	
	routes:
		"groups/new"		: "new"
		"groups/:id"		: "show"
		"groups/:id/edit" 	: "edit"

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