class Facebook
	
	authorize: ->
		FB.login()
		
	logged_in: ->
		true unless FB.getSession() is undefined
		
	name: (fn) ->
		if @logged_in()
			FB.api "/me", (resp) ->
				fn(resp.name)
			return null