App.Views.Databases or= {}

class App.Views.Databases.Index extends Backbone.View
	
	events:
		'click .delete' : "delete"
	
	initialize: ->	
		$('.breadcrumb').remove()
		
		$(@el).before ich.breadcrumb 
			crumbs: [
				{url:'/databases', title:'Home'}
			]

	render: ->
		self = @
		$.getJSON '/databases.json', (items) ->
			$(self.el).html ich.database_list
				databases: items

		
	delete: (e) ->
		self = @
		$.ajax
			type: "POST"
			url: $(e.currentTarget).attr('href')
			data: {_method: 'DELETE'}
			success: (data, status, xhr) ->
				self.render()
		return false