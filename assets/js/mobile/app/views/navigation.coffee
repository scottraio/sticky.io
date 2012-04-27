class Mob.Views.Navigation extends Backbone.View
	
	events:
		"tap li" : "jump"
		
	jump: (e) ->
		mobui.set_navbar($("a", $(e.currentTarget)).attr("data-tabbar-item"))
		return false