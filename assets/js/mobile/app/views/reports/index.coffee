Mob.Views.Reports or= {}

class Mob.Views.Reports.Index extends Backbone.View
	
	initialize: ->
		mobui.clear()
		
		mobui.set_title("Reports")
		mobui.add_button("/reports/new")
		
	render: -> 	
		$("#content").html ich.navlist
			items: this.options.items, 
			url: () -> "/reports/#{ this.id }", 
			time_ago_in_words: () -> $.timeago(this.created_at),
			title: () -> this.name || "None",
			class: () -> this.name ? "" : "empty"