App.Views.Users or= {}

class App.Views.Users.Edit extends Backbone.View

	events:
		'submit form' 				: 'save'
		'click ul.themes li' 	: 'select_theme'

	initialize: () ->
		@user = new App.Models.User(id: @options.id)

		$('#settings').on 'hidden', () ->
			navigate '/'

	render: () ->
		self = @
		@user.fetch
			success: (err, user) -> 
				$(self.el).modal()		
				$(self.el).show()
				$("li[data-value=#{current_user.theme}]").addClass('selected')

	bookmarklet_js: () ->
		"javascript:void((function()%7Bvar%20e%3Ddocument.createElement(%27script%27)%3Be.setAttribute(%27type%27,%27text/javascript%27)%3Be.setAttribute(%27charset%27,%27UTF-8%27)%3Be.setAttribute(%27src%27,%27http://dev.sticky.io:8000/js/bookmarklet.js%3Fr%3D%27%2BMath.random()*99999999)%3Bdocument.body.appendChild(e)%7D)())%3B"

	save: (e) ->
		self = @
		e.preventDefault()

		attrs = $('form', @el).serializeObject()

		save @user, attrs, {
			success: (data, res) ->
				$(self.el).modal('hide')
			error: (data, res) ->
				console.log 'error'
		}

		return false

	select_theme: (e) ->
		# set the input
		theme = $(e.currentTarget).attr('data-value')
		$('input[name=theme]').val theme
		# now show the color as being selected
		$('ul.themes li').removeClass('selected')
		# select the theme inside the settings modal
		$(e.currentTarget).addClass('selected')
		# set the body class to the newly selected theme
		$('body').removeClass()
		$('body').addClass('theme-' + theme)
		return false
