#
#
# Controllers Main - Hybrid application_controller/routes
#
#
fs 									= require 'fs'
passport 						= require 'sticky-passport'
Resource						= require 'express-resource'
UsersController			= require './users_controller'
NotesController			= require './notes_controller'
NotebooksController	= require './notebooks_controller'


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
app.post('/login', passport.authenticate('local', { successRedirect: '/', failureRedirect: '/', failureFlash: true }))
app.get('/logout', UsersController.logout)
app.get('/signup', UsersController.signup)
app.post('/signup', UsersController.create)
app.get('/settings', ensureAuthenticated, UsersController.edit)

# Forces registration for XMPP Roster
app.get('/register', ensureAuthenticated, UsersController.register)

# Dummy route for welcome dialog
app.get('/welcome', ensureAuthenticated, NotesController.index)

# Redirect the user to Google for authentication.  When complete, Google
# will redirect the user back to the application at
# /auth/google/callback
app.get('/auth/google', passport.authenticate('google', { scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'] }))

# Google will redirect the user to this URL after authentication.  Finish
# the process by verifying the assertion.  If valid, the user will be
# logged in.  Otherwise, authentication has failed.
app.get('/auth/google/callback', passport.authenticate('google', { failureRedirect: '/' }), (req,res) -> res.redirect('/') )

#
# Notes
#
app.get('/notes.:format?', ensureAuthenticated, NotesController.index)
app.get('/notes/:id.:format?', ensureAuthenticated, NotesController.show)
app.get('/notes/new.:format?', ensureAuthenticated, NotesController.new)
app.get('/notes/:id/edit.:format?', ensureAuthenticated, NotesController.edit)
app.post('/notes.:format?', ensureAuthenticated, NotesController.create)
app.delete('/notes/:id.:format?', ensureAuthenticated, NotesController.delete)
app.put('/notes/:id.:format?', ensureAuthenticated, NotesController.update)

#
# Notes Tree
#
app.get('/notes/:id/expanded.:format?', ensureAuthenticated, NotesController.expanded)
app.get('/notes/:id/stack/:parent_id.:format?', ensureAuthenticated, NotesController.stack)
app.get('/notes/:id/unstack/:parent_id.:format?', ensureAuthenticated, NotesController.unstack)
app.get('/notes/:id/restack/:from_id/:to_id.:format?', ensureAuthenticated, NotesController.restack)

#
# Notebooks
#
app.get('/notebooks.:format?', ensureAuthenticated, NotebooksController.index)
app.get('/notebooks/:id/accept.:format?', ensureAuthenticated, NotebooksController.accept_invite)
app.get('/notebooks/:id/members/:user_id/remove.:format?', ensureAuthenticated, NotebooksController.remove_member)
app.get('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.show)
app.post('/notebooks.:format?', ensureAuthenticated, NotebooksController.create)
app.put('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.update)
app.delete('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.delete)

#
# Root
#

app.get '/', (req, res) ->
	if req.isAuthenticated()
		NotesController.index(req,res)
	else
		res.render('public', {current_user:null})

