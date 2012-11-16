App.Views.Users or= {}

class App.Views.Users.Welcome extends Backbone.View

	events:
		"submit .confirm-sms form" : "confirm_phone_number"

	initialize: () ->
		# enable the carousel for first time users
		$('.carousel').carousel('pause')

		# when finished, redirect to root path
		$('#welcome').on 'hidden', () ->
			navigate '/'

	render: () ->
		$(@el).modal()		

	confirm_phone_number: (e) ->
		$.post "/users/#{current_user._id}/confirm_phone", (data) ->
			console.log data

		return false
