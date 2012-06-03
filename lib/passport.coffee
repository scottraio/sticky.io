passport 		= require('passport')
LocalStrategy 	= require('passport-local').Strategy
BasicStrategy 	= require('passport-http').BasicStrategy
GoogleStrategy 	= require('passport-google-oauth').OAuth2Strategy

#
# Auth with HTML form
#

passport.use(new LocalStrategy (username, password, done) ->
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 											if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) 	if !user.validPassword(password)
		return done(null, user)
)

#
# Auth with HTTP Basic
#

passport.use(new BasicStrategy (username, password, done) ->
	console.log username
	console.log password
	app.models.User.findOne { email: username }, (err, user) ->
		return done(err) 											if (err)
		return done(null, false, { message: 'Unknown user' }) 		if !user
		return done(null, false, { message: 'Invalid password' }) 	if !user.validPassword(password)
		return done(null, user)
)

#
# Auth with Google
#

google_config = {
	clientID: app.config.google_oauth.client_id,
	clientSecret: app.config.google_oauth.secret,
	callbackURL: "http://#{app.config.domain}#{app.config.google_oauth.redirect}"
}

passport.use(new GoogleStrategy google_config, (accessToken, refreshToken, profile, done) ->
    
    # first attepmt to find the user their profile.id
    app.models.User.findOne { googleId: profile.id }, (err, user) -> 
    	unless user
    		app.models.User.findOne { email: profile._json.email }, (err, user) -> 
    			unless user
	    			user = new app.models.User 
	    				name 	 : profile.displayName
	    				email 	 : profile._json.email
	    				password : Math.random().toString(36).substring(7)
	    				googleId : profile.id
	    			user.save (err) ->
	    				done(err, user)
	    		else
	    			user.set 'googleId', profile.id
	    			user.save (err) ->
	    				done(err, user)
    	else
    		
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