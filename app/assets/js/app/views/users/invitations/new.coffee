App.Views.Users or= {}
App.Views.Users.Invitations or= {}

class App.Views.Users.Invitations.New extends Backbone.View
	
	events:
		"click #submit-invite-user-form" : "submit"
	
	initialize: ->
		# focus the first textbox
		facebox_auto_focus(@el)
		
	submit: (e) ->		
		disable_button $(e.currentTarget)
		
		ajax = $.ajax
			type: "POST"
			url: $(e.currentTarget).closest('form').attr('action')
			data: $(e.currentTarget).closest('form').serialize()
			dataType: "json"
			complete: (data, status, xhr) ->
				navigate "/users"
				close_all_pops()
				
		return false
