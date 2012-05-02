App.Views.Databases or= {}

class App.Views.Databases.Index extends Backbone.View
	
	initialize: ->	
		$('.breadcrumb').remove()
		
		$(@el).before ich.breadcrumb 
			crumbs: [
				{url:'/databases', title:'Home'}
			]

	render: ->
		self = @
		$.getJSON '/databases.json', (items) ->
			$(self.el).html ich.database_list
				databases: items

		
