#p arseCookie = require('connect').utils.parseCookie


exports.start = (server) ->

	io = require('socket.io').listen(server)
	 
	#io.set 'authorization', (data, accept) ->
		# check if there's a cookie header
	#	if data.headers.cookie
			# if there is, parse the cookie
	#		data.cookie = parseCookie(data.headers.cookie)
			# note that you will need to use the same key to grad the
			# session id, as you specified in the Express setup.
	#		data.sessionID = data.cookie['express.sid']
	#	else
			# if there isn't, turn down the connection with a message
			# and leave the function.
	#		return accept('No cookie transmitted.', false)
	    
		# accept the incoming connection
	#	accept(null, true)

	# Socket IO
	io.sockets.on 'connection', (socket) ->

		socket.emit('news', { hello: 'world' })

		socket.on 'my other event', (data) ->
	    	console.log(data)
