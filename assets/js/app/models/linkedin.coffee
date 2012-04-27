class LinkedIn
	
	authorize: ->
		IN.User.authorize()
		
	logged_in: ->
		try 
			true unless IN.User.isAuthorized() isnt true
		catch error
			console.log error
			
	name: (fn) ->
		if @logged_in()
			IN.API.Profile("me").result (result) ->
				user = result.values[0]
				name = "#{user.firstName} #{user.lastName}"
				fn(name)