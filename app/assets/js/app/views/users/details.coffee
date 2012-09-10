App.Views.Users or= {}

class App.Views.Users.Details extends Backbone.View
	
	initialize: ->
		# focus the first textbox
		facebox_auto_focus(@el)
		# set the settings nav height
		settings_auto_adjust(@el)
		
