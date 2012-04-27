App.Views.Templates or= {}

class App.Views.Templates.Index extends Backbone.View

	
	events:
		"click ul.categories .link" : "load_category"
	
	initialize: ->
		reset_events @
	
	load_category: (e) ->
		li = $(e.currentTarget)
		remote_get("#stage", "/templates?category_id=#{li.attr('rel')}", true)
		return false
