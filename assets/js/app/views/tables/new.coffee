App.Views.Tables or= {}

class App.Views.Tables.New extends Backbone.View
	
	initialize: ->	
		
	render: ->
		self = @
		$(self.el).html ich.table_form
			database_id : self.options.database_id
		
