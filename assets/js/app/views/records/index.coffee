App.Views.Records or= {}

class App.Views.Records.Index extends Backbone.View
	
	events:
		'click .delete' : "delete"
	
	initialize: ->	
		@collections_path 	= "/#{@options.database_id}/collections"
		@records_path 		= "/#{@options.database_id}/#{@options.collection_id}/records"

		$('.breadcrumb').remove()

		$(@el).before ich.breadcrumb 
			crumbs: [
				{url:'/databases', title:'Home'},
				{url:@collections_path, title:@options.database_id, sep:true},
				{url:@records_path, title:@options.collection_id, sep:true}
			]
		
	render: ->
		self = @
		$.getJSON "#{@records_path}.json", (items) ->
			$(self.el).html ich.record_list
				records : items
				records_path: self.records_path

	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href')
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false