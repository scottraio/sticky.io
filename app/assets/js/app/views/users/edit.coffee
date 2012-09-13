App.Views.Users or= {}

class App.Views.Users.Edit extends Backbone.View

	initialize: () ->

	render: () ->
		self = @

		$('#stage').html ich.settings
			bookmarklet_js: self.bookmarklet_js()
		
		$('#expanded-view').html('')

	bookmarklet_js: () ->
		"javascript:void((function()%7Bvar%20e%3Ddocument.createElement(%27script%27)%3Be.setAttribute(%27type%27,%27text/javascript%27)%3Be.setAttribute(%27charset%27,%27UTF-8%27)%3Be.setAttribute(%27src%27,%27http://dev.sticky.io:8000/js/bookmarklet.js%3Fr%3D%27%2BMath.random()*99999999)%3Bdocument.body.appendChild(e)%7D)())%3B"
