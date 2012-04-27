class Mob.Views.ListView extends Backbone.View
	
	events:
		"tap ul[data-role=listview] li" 	: "select"
		
	initialize: ->
	
	select: (e) -> 
		$(e.currentTarget).addClass("pressed")
		mobui.set_title($(e.currentTarget).find("a")[0].text)
		window.location.hash = $(e.currentTarget).find("a").attr("href")