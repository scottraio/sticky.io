App.Views.Groups or= {}

class App.Views.Groups.Show extends Backbone.View
		
	
	initialize: ->
		@group = new App.Models.Group(id: @options.id)

	render: () ->
		@group.fetch
			success: (col, groupJSON) ->

				$('#stage').html ich.groups_list
					notes: groupJSON.notes
					group: groupJSON.group
					created_at_in_words: () -> $.timeago(this.created_at)
				$('.autolink').autolink()