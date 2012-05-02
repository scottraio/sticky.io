App.Views.Tables or= {}

class App.Views.Tables.Index extends Backbone.View
	
	initialize: ->	
		@url = "/#{@options.database_id}/tables"

		$('.breadcrumb').remove()

		$(@el).before ich.breadcrumb 
			crumbs: [
				{url:'/databases', title:'Home'},
				{url:@url, title:@options.database_id, sep:true}
			]
		
	render: ->
		self = @
		$.getJSON "#{@url}.json", (items) ->
			$(self.el).html ich.table_list
				tables 	: items
				db_id	: self.options.database_id

		
