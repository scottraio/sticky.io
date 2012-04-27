App.Views.Users or= {}

class App.Views.Users.Edit extends Backbone.View
	
	events:
		"click .popup_new_window" : "popup_new_window"
		
	popup_new_window: (e) ->
		window.open $(e.currentTarget).attr("href"), "Connect with web services", "status=0,toolbar=0,width=600,height=300"
		return false