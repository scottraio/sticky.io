sio 		= require('socket.io')
redis 	= require('redis')

exports.start = (server, cookieParser, sessionStore) ->

	RedisStore = sio.RedisStore
	GLOBAL.io = sio.listen(server)

	#io.set 'transports', ['xhr-polling']

	io.configure () ->
		pub    = redis.createClient(settings.redis.port, settings.redis.server)
		sub    = redis.createClient(settings.redis.port, settings.redis.server)
		client = redis.createClient(settings.redis.port, settings.redis.server)

		io.set('store', new RedisStore( { redisPub: pub, redisSub: sub, redisClient: client } ))
	 
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
		client 					= redis.createClient(settings.redis.port, settings.redis.server)

		if current_user_id
			sockets_for_user = "sockets_for_#{current_user_id}"

			client.get sockets_for_user, (err, reply) ->
				console.log reply
				if reply 
					bucket = JSON.parse(reply)
					bucket.push socket.id
					client.set sockets_for_user, JSON.stringify(bucket), redis.print
				else
					client.set sockets_for_user, JSON.stringify([socket.id]), redis.print

	io.sockets.on 'disconnect', (socket) ->
		console.log 'good bye socket'


