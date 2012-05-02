App.Views.Records or= {}

class App.Views.Records.Index extends Backbone.View
	
	initialize: ->	
		@tables_path 	= "/#{@options.database_id}/tables"
		@records_path 	= "/#{@options.database_id}/#{@options.table_id}/records"

		$('.breadcrumb').remove()

		$(@el).before ich.breadcrumb 
			crumbs: [
				{url:'/databases', title:'Home'},
				{url:@tables_path, title:@options.database_id, sep:true},
				{url:@records_path, title:@options.table_id, sep:true}
			]
		
	render: ->
		self = @
		$.getJSON "#{@records_path}.json", (items) ->
			$(self.el).html ich.record_list
				records 	: items
				database_id	: self.options.database_id
				table_id	: self.options.table_id

		
