class App.Routers.DatabasesRouter extends Backbone.Router
	
	routes:
		"databases"				: "index"
		"databases/new"			: "new"
		"databases/:id"			: "show"
		"databases/:id/edit" 	: "edit"
	
	index: ->
		render_with_facebox () ->
			# set the settings nav height
			settings_auto_adjust(@el)
			return false # nothing here yet
	
	new: ->
		render_with_facebox () ->
			new App.Views.Databases.New(el: $("#facebox .content"))
	
	show: ->
		render_with_facebox () ->
			return false
		
	edit: (book_id) ->
		render_with_facebox () ->
			new App.Views.Databases.New(el: $("#facebox .content"))