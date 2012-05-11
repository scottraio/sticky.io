App.Views.Records or= {}

class App.Views.Records.New extends Backbone.View
	
	initialize: ->	
		
	render: ->
		self = @
		$(self.el).html ich.record_form
			database_id 	: self.options.database_id
			collection_id	: self.options.collection_id
		
