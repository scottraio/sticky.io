App.Views.Users or= {}

class App.Views.Users.ConfirmPhoneNumber extends Backbone.View

	events:
		"submit form" : "submit"

	render: () ->
		$(@el).modal()		
		$(@el).show()

		$(@el).on 'shown', () ->
			$('input', @el).focus()


	submit: (e) ->		
		number = $('input[name=phone_number]', @el).val()
		$.post "/users/#{current_user._id}/confirm_phone_number.json", {phone_number: number}, (data) ->
			$('#confirm-code').show()
			$('#confirm-code input').focus()


		return false
