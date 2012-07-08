App.Views.Groups or= {}

class App.Views.Groups.Index extends Backbone.View
		
	
	initialize: ->
		@groups 	= new App.Collections.Groups()

	render: () ->
		self = @
		# load notebooks
		@groups.fetch
			success: (col, items) ->
				$('#stage').html ich.groups_board
						notebooks: items