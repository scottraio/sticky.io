_ 			= require('underscore')
sio 		= require('socket.io')
routes 	= require('../app/sockets')

exports.start = (server, cookieParser, sessionStore, redisclient) ->

	_cookie 			= 'connect.sid'
	_cookieParser = cookieParser
	_sessionStore = sessionStore

	RedisStore = sio.RedisStore
	GLOBAL.io = sio.listen(server)

	io.configure () ->
		#
		# I guess socket.io needs a redis store, on top of the redis session, integrated
		# with the redis socket bucket. What a mess. Either I don't understand socket programming
		# well enough or theres a better implementation. 
		#pub    = redis.createClient(settings.redis.port, settings.redis.server)
		#sub    = redis.createClient(settings.redis.port, settings.redis.server)
		#client = redis.createClient(settings.redis.port, settings.redis.server)

		io.set('store', new RedisStore( { redisPub: redisclient, redisSub: redisclient, redisClient: redisclient } ))

		if app.env is 'production'
			# send minified client
			# io.enable('browser client minification')  
			# apply etag caching logic based on version number
			io.enable('browser client etag')
			# gzip the file
			io.enable('browser client gzip')
			# reduce logging
			io.set('log level', 1)
			# enable all transports (optional if you want flashsocket)
			io.set('transports', [ 'websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling' ])

	io.sockets.on 'connection', (socket) ->
		#
		# For security, hook right into the session. Once the passport
		# object is safely secured, we can grab the user._id and begin adding the socket.id
		# to the list of open sockets stored in the User object with Mongo. 
		current_user_id = socket.handshake.session.passport.user

		#
		# grab the current session to only allow 1 socket connection per session
		current_session_id = socket.handshake.session.id
		#
		# proceed if cool
		if current_user_id
			
			#
			# Here's where the magic happens. We store each socket.id connected from an User session. 
			# By doing this, it assures that only approved, connected sockets will get pushed new data.
			app.models.User.findOne {_id: current_user_id}, (err, user) ->
				socket.join(user._id)
				# grab any existing socket and either update the user bucket or set a new one	
				#app.models.User.sync_socket_with_session user, current_session_id, socket, () ->
				#	console.log 'info: sockets synced with session'					


		# Bind all socket application "routes"
		# i.e. stacking, unstacking, restacking
		routes.bind(current_user_id, socket)

		# gracefully handle disconnects
		socket.on 'disconnect', (data) ->
			console.log 'disconnect'
			# remove the socket.id once the user disconnects, simple right?
			app.models.User.update { _id: current_user_id}, { '$pullAll': {'sockets.sockets': [socket.id] }}, () ->
				# done

	#
	# Authorize every socket connection with the existing session.
	io.set 'authorization', (data, accept) ->		
		if (data && data.headers && data.headers.cookie)
			_cookieParser data, {}, (err) ->
				return accept('COOKIE_PARSE_ERROR') if(err)
				sessionId = data.signedCookies[_cookie]
				_sessionStore.get sessionId, (err, session) ->
					if(err || !session || !session.passport || !session.passport.user)
						accept('NOT_LOGGED_IN', false)
					else
						data.session 		= session
						data.session.id = sessionId
						accept(null, true)
		else
			return accept('MISSING_COOKIE', false);
