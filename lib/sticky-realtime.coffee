_ 			= require('underscore')

sio 		= require('socket.io')
redis 	= require('redis')

exports.start = (server, cookieParser, sessionStore) ->

	RedisStore = sio.RedisStore
	GLOBAL.io = sio.listen(server)

	#io.set 'transports', ['xhr-polling']

	io.configure () ->
		#
		# I guess socket.io needs a redis store, on top of the redis session, integrated
		# with the redis socket bucket. What a mess. Either I don't understand socket programming
		# well enough or theres a better implementation. 
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

		#
		# The way this technique is secure is by hooking right into the session. Once the passport
		# object is safely secured, we can grab the user._id and begin the redis mess. 
		current_user_id = socket.handshake.session.passport.user
		# Open a new client to redis 
		client = redis.createClient(settings.redis.port, settings.redis.server)

		# proceed if cool
		if current_user_id
			# set the name
			sockets_for_user = "sockets_for_#{current_user_id}"
			# grab any existing socket from redis and either update the user bucket or set a new one
			client.get sockets_for_user, (err, reply) ->
				if reply 
					bucket = JSON.parse(reply)
					bucket.push socket.id
					# if the bucket size is greater than 3, then lets reset the sockets, otherwise
					# add it to the stack
					if bucket.size > 3 
						client.set sockets_for_user, JSON.stringify([socket.id]), redis.print
					else
						client.set sockets_for_user, JSON.stringify(bucket), redis.print
				else
					# just set the bucket to an array with the value of the first socket
					client.set sockets_for_user, JSON.stringify([socket.id]), redis.print
