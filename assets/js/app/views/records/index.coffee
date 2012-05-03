App.Views.Records or= {}

class App.Views.Records.Index extends Backbone.View
	
	events:
		'click .delete' : "delete"
	
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
				records : items
				db_id	: self.options.database_id
				tbl_id	: self.options.table_id

	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href')
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false