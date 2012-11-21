App.Views.Users or= {}

class App.Views.Users.ConfirmPhoneNumber extends Backbone.View

	events:
		"submit form" : "submit"

	render: () ->
		$('#settings').modal('hide')		

		$(@el).on 'shown', () ->
			$('input', @el).focus()

		$(@el).modal('show')

	submit: (e) ->		
		self 					= @
		number 				= $('input[name=phone_number]', @el).val()
		confirm_code 	= $('input[name=phone_number_confirm_token]', @el).val()

		if confirm_code
			$.post "/users/#{current_user._id}/auth_phone_number.json", {phone_number_confirm_token: confirm_code, phone_number: number}, (data) ->
				$(self.el).modal('hide')
		else
			$.post "/users/#{current_user._id}/confirm_phone_number.json", {phone_number: number}, (data) ->
				$('#confirm-code').show()
				$('#confirm-code input').focus()


		return false
