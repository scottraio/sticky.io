passport 				= require('passport')
LocalStrategy 	= require('passport-local').Strategy
BasicStrategy 	= require('passport-http').BasicStrategy
GoogleStrategy 	= require('passport-google-oauth').OAuth2Strategy

#
# Auth with HTML form
#

passport.use(new LocalStrategy (username, password, done) ->
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 																					if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) if !user.validPassword(password)
		return done(null, user)
)

#
# Auth with HTTP Basic
#

passport.use(new BasicStrategy (username, password, done) ->
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 																					if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) if !user.validPassword(password)
		return done(null, user)
)

#
# Auth with Google
#

google_config = {
	clientID: settings.google_oauth.client_id,
	clientSecret: settings.google_oauth.secret,
	callbackURL: "http://#{settings.domain}#{settings.google_oauth.redirect}"
}

passport.use(new GoogleStrategy google_config, (accessToken, refreshToken, profile, done) ->
		# first attepmt to find the user their profile.id
		app.models.User.findOne { googleId: profile.id }, (err, user) -> 
			unless user
				# if they've sign-up through the signup, and haven't authed through google before
				# attept to find the user and assign a googleId to him/her
				app.models.User.findOne { email: profile._json.email }, (err, user) -> 
					unless user
						# if we cant find a user, create a new one!
						user = new app.models.User 
							name 	 		: profile.displayName
							email 	 	: profile._json.email
							password 	: Math.random().toString(36).substring(7)
							googleId 	: profile.id
						user.save (err) ->
							user.registerXMPPBot()
							user.sendWelcomeEmail()
							user.setupDefaultNotebooks()
							done(err, user)
					else
						user.set 'googleId', profile.id
						user.save (err) ->
							done(err, user)
			else	
				user.set 'last_sign_in_at', new Date()
				user.save (err) ->
					return done(err, user)
)

#
# Serialize User
#

passport.serializeUser (user, done) ->
	done(null, user.id)

passport.deserializeUser (id, done) ->
	app.models.User.findById id, (err, user) ->
		done(err, user)

module.exports = passport
