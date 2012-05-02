passport 		= require('passport')
LocalStrategy 	= require('passport-local').Strategy
BasicStrategy 	= require('passport-http').BasicStrategy

passport.use(new LocalStrategy (username, password, done) ->
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 											if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) 	if !user.validPassword(password)
		return done(null, user)
)

passport.use(new BasicStrategy (username, password, done) ->
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 											if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) 	if !user.validPassword(password)
		return done(null, user)
)

passport.serializeUser (user, done) ->
	done(null, user.id)

passport.deserializeUser (id, done) ->
	app.models.User.findById id, (err, user) ->
		done(err, user)

module.exports = passport