App.Views.Databases or= {}

class App.Views.Databases.Show extends Backbone.View
	
	initialize: ->	
		
	render: ->
		$(@el).html ich.database_details()
		
