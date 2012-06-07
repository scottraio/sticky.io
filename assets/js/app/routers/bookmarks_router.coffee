class App.Routers.BookmarksRouter extends Backbone.Router
	
	routes:
		"bookmarks"	: "index"
	
	index: ->
		if current_user
			notes = new App.Views.Bookmarks.Index(el: $("#stage"))
			notes.render()