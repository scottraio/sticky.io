class App.Routers.DocsRouter extends Backbone.Router
	
	routes:
		"docs" : "index"
	
	index: ->
		$(".docs-nav").collapse()