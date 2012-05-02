App.Views.Records or= {}

class App.Views.Records.New extends Backbone.View
	
	initialize: ->	
		
	render: ->
		self = @
		$(self.el).html ich.record_form
			database_id : self.options.database_id
			table_id	: self.options.table_id
		
