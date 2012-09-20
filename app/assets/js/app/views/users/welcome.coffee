App.Views.Users or= {}

class App.Views.Users.Welcome extends Backbone.View

	initialize: () ->
		$('#welcome').on 'hidden', () ->
			navigate '/'

	render: () ->
		$(@el).modal()		
