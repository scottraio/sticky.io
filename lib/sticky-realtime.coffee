#cookieParser = express.cookieParser('sc2ishard')

exports.start = (server, cookieParser, sessionStore) ->

	GLOBAL.io = require('socket.io').listen(server)

	#io.set 'transports', ['xhr-polling']
	 
	# Socket.io

	GLOBAL.socketbucket = {}

	_cookie 			= 'connect.sid'
	_cookieParser = cookieParser
	_sessionStore = sessionStore
    
	io.set 'authorization', (data, accept) ->		
		if (data && data.headers && data.headers.cookie)
			_cookieParser data, {}, (err) ->
				return accept('COOKIE_PARSE_ERROR') if(err)
				sessionId = data.signedCookies[_cookie]
				_sessionStore.get sessionId, (err, session) ->
					if(err || !session || !session.passport || !session.passport.user)
						accept('NOT_LOGGED_IN', false)
					else
						data.session = session
						accept(null, true)
		else
			return accept('MISSING_COOKIE', false);


	io.sockets.on 'connection', (socket) ->

		current_user_id = socket.handshake.session.passport.user

		if current_user_id
			if socketbucket[current_user_id] && socketbucket[current_user_id].length > 0
				socketbucket[current_user_id].push socket.id
			else
				socketbucket[current_user_id] = [socket.id]

