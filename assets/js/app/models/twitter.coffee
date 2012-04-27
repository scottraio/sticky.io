class Twitter
	
	authorize: ->
		twttr.anywhere (T) ->
			T.signIn()
		
	logged_in: ->
		twttr.anywhere (T) ->
			T.isConnected()

