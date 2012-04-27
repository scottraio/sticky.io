class Google
	
	authorize: () ->
		google.accounts.user.login(scope)
