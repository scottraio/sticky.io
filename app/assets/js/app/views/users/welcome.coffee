App.Views.Users or= {}

class App.Views.Users.Welcome extends Backbone.View

	initialize: () ->
		mixpanel.people.set
			"$email": current_user.email,
			"$name": current_user.name

		$('#welcome').on 'hidden', () ->
			navigate '/'

	render: () ->
		$(@el).modal()		
