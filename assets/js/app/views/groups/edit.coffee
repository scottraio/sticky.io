App.Views.Groups or= {}

class App.Views.Groups.Edit extends Backbone.View
	
	events:
		'submit form' 			: 'submit'
		'button[type=submit]'	: 'submit'
		'click .delete'			: 'delete'	
	
	initialize: ->
		@group 		= new App.Models.Group(id: @options.id)

	render: () ->
		self = @
		@group.fetch 
			success: (err, groupJSON) -> 
				# show the modal window
				$(self.el).modal('show')

				# load the view
				$(self.el).html ich.groups_form
					group 		: groupJSON
					save_label 	: "Save notebook"
					users_email : () -> _.pluck(groupJSON._users, 'email')
					is_update 	: true

				# focus on the name
				$('input.name', self.el).focus()

				# init the members controls
				new App.Views.Groups.Members(el: $("#members")) 

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
				# reload the view
				window.location.href = '/'

			error: (data, res) ->
				console.log 'error'
		}
		
		return false
	
	delete: (e) ->
		self = @
		@group.destroy
			success: (res) ->
				$(self.el).modal('hide')
				window.location.href = '/'
		return false

		