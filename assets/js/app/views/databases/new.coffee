App.Views.Databases or= {}

class App.Views.Databases.New extends Backbone.View
	
	initialize: ->	
		
	render: ->
		$(@el).html ich.database_form()
		
