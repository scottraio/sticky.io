Mob.Views.Reports or= {}

class Mob.Views.Reports.Show extends Backbone.View
	
	initialize: ->
		mobui.clear()
		
		mobui.back_button("Back")
	
	render: ->
		self = this
		#$("section#sub-header").html ich.gridheader()
		
		$("#content").html ich.navlist(
			items: this.options.items, 
			url: () -> "/reports/#{self.options.id}/records/#{ this.id }", 
			time_ago_in_words: () -> $.timeago(this.created_at), 
			title: () -> this.name || "None",
			class: () -> this.name ? "" : "empty"
		)
		
		window.scroller.set_height()