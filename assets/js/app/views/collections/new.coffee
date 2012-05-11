App.Views.Collections or= {}

class App.Views.Collections.New extends Backbone.View
	
	initialize: ->	
		
	render: ->
		self = @
		$(self.el).html ich.collection_form
			database_id : self.options.database_id
		
