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
		$(@el).html ich.groups_form
			save_label : "Create Notebook"

	submit: (e) ->
		self = @
		attrs = $('form', @el).serializeObject()

		save @group, attrs, {
			success: (data, res) ->
				# reload the view by refreshing the page
				# we do this because a big chunk of the navigation 
				# is built at page load
				window.location.href = "/groups/#{res._id}"

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
	
		