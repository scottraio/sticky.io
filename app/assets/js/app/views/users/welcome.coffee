App.Views.Users or= {}

class App.Views.Users.Welcome extends Backbone.View

	initialize: () ->

		# enable the carousel for first time users
		$('.carousel').carousel('pause')

		# when finished, redirect to root path
		$('#welcome').on 'hidden', () ->
			navigate '/'

	render: () ->
		$(@el).modal()		
