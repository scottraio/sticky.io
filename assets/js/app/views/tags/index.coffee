App.Views.Tags or= {}

class App.Views.Tags.Index extends Backbone.View
	
	initialize: ->	

	render: ->
		$.getJSON '/tags.json', (tags) ->
			$('#tags').html ich.tag_list 
				tags : tags