App.Views.Groups or= {}

class App.Views.Groups.New extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'button[type=submit]'	: 'submit'
	
	initialize: ->
		@group = new App.Models.Group()

	render: () ->
		$(@el).modal('show')
		$('input.name', @el).focus()

	submit: (e) ->
		self = @
		attrs = {
			name: $('input.name', @el).val()
			members:  $('textarea.members', @el).val().split(",")
		}

		save @group, attrs, {
			success: (data, res) ->
				# close modal window
				$(self.el).modal('hide')
				$('input.name', self.el).val("")
				$('textarea.members', self.el).val("")
				# reload the view
				push_url '/'

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
	
		