App.Views.Databases or= {}

class App.Views.Databases.Index extends Backbone.View
	
	initialize: ->	
		
	render: ->
		self = @
		$.getJSON '/databases.json', (items) ->
			$(self.el).html ich.database_list
				databases: items

		
