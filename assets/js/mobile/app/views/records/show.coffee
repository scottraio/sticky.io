Mob.Views.Records or= {}

class Mob.Views.Records.Show extends Backbone.View
		
	initialize: ->	
		mobui.set_title this.options.item.name
		mobui.back_button("Back")
	
	render: =>
		$("#content").html ich.recordshow
			item: this.options.item
			values: this.options.item.values
			time_ago_in_words: () -> $.timeago(this.created_at)