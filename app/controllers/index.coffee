#
#
# Controllers Main - Hybrid application_controller/routes
#
#
fs 						= require 'fs'
passport 				= require '../../lib/passport'
Resource				= require '../../lib/express_resource'
UsersController			= require './users'
NotesController			= require './notes'
TagsController			= require './tags'
BookmarksController		= require './bookmarks'

ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		return next() 
	else
		if req.params.format is 'json'
			passport.authenticate('basic',{session:false})(req, res, next)
		else
			return next()

#
# Authentication
# 
app.get('/login', UsersController.login)
app.post('/login', passport.authenticate('local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true }))
app.get('/logout', UsersController.logout)
app.get('/signup', UsersController.signup)
app.post('/signup', UsersController.create)

# Forces registration for XMPP Roster
app.get('/register', ensureAuthenticated, UsersController.register)

# Redirect the user to Google for authentication.  When complete, Google
# will redirect the user back to the application at
# /auth/google/callback
app.get('/auth/google', passport.authenticate('google', { scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'] }))

# Google will redirect the user to this URL after authentication.  Finish
# the process by verifying the assertion.  If valid, the user will be
# logged in.  Otherwise, authentication has failed.
app.get('/auth/google/callback', passport.authenticate('google', { failureRedirect: '/login' }), (req,res) -> res.redirect('/') )

#
# Notes
#
app.post('/notes/filter.:format?', NotesController.filter)
app.get('/notes.:format?', ensureAuthenticated, NotesController.index)
app.get('/notes/:id.:format?', ensureAuthenticated, NotesController.show)
app.get('/notes/new.:format?', ensureAuthenticated, NotesController.new)
app.get('/notes/:id/edit.:format?', ensureAuthenticated, NotesController.edit)
app.post('/notes.:format?', ensureAuthenticated, NotesController.create)
app.delete('/notes/:id.:format?', ensureAuthenticated, NotesController.delete)
app.put('/notes/:id.:format?', ensureAuthenticated, NotesController.update)

#
# Tags
#

app.get('/tags.:format?', ensureAuthenticated, TagsController.index)
app.get('/tags/reset', ensureAuthenticated, TagsController.reset)

#
# Bookmarks
#

app.get('/bookmarks.:format?', ensureAuthenticated, BookmarksController.index)

#
# Root
#

app.get '/', NotesController.index

