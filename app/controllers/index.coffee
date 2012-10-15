#
#
# Controllers Index - Hybrid application_controller/routes
#
#
fs 									= require 'fs'
passport 						= require 'sticky-passport'
render							= require 'sticky-render'
Resource						= require 'express-resource'
UsersController			= require './users_controller'
NotesController			= require './notes_controller'
NotebooksController	= require './notebooks_controller'

#
# Middleware
ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		return next() 
	else
		if req.params.format is 'json'
			passport.authenticate('basic',{session:false})(req, res, next)
		else
			renderPublic(req, res, next)

renderPublic = (req, res, next) ->
	unless req.isAuthenticated()
		if render.is_mobile(req)
			res.render 'mobile/public', {}
		else
			#res.setHeader "Cache-Control", "public, max-age=#{5 * 60}"
			res.render 'public', {current_user:null}
	else
		next()


#
# Routes
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
app.get('/auth/google/callback', passport.authenticate('google', { failureRedirect: '/' }), (req,res) -> 
	new_user = true if req.user.last_sign_in_at is null
	app.models.User.findOne {'_id':req.user._id}, (err, user) ->
		user.set 'last_sign_in_at', new Date()	
		user.save (err,user) ->
			console.log(err) if err
			if new_user
				res.redirect('/welcome') 
			else 
				res.redirect('/notes') 
)


#
# Users
app.get('/users/:id.:format?', ensureAuthenticated, UsersController.show)
app.put('/users/:id.:format?', ensureAuthenticated, UsersController.update)

#
# Notes
app.get('/notes.:format?', ensureAuthenticated, NotesController.index)
app.get('/notes/:id.:format?', ensureAuthenticated, NotesController.show)
app.get('/notes/new.:format?', ensureAuthenticated, NotesController.new)
app.get('/notes/:id/edit.:format?', ensureAuthenticated, NotesController.edit)
app.post('/notes.:format?', ensureAuthenticated, NotesController.create)
app.delete('/notes/:id.:format?', ensureAuthenticated, NotesController.delete)
app.put('/notes/:id.:format?', ensureAuthenticated, NotesController.update)
app.post('/notes/smtp.:format?', NotesController.smtp)

#
# Notes Tree
app.get('/notes/:id/expanded.:format?', ensureAuthenticated, NotesController.expanded)
app.get('/notes/:child_id/stack/:parent_id.:format?', ensureAuthenticated, NotesController.stack)
app.get('/notes/:child_id/unstack/:parent_id.:format?', ensureAuthenticated, NotesController.unstack)
app.get('/notes/:child_id/restack/:old_id/:parent_id.:format?', ensureAuthenticated, NotesController.restack)

#
# Notebooks
app.get('/notebooks.:format?', ensureAuthenticated, NotebooksController.index)
app.get('/notebooks/:id/accept.:format?', ensureAuthenticated, NotebooksController.accept_invite)
app.get('/notebooks/:id/members/:user_id/remove.:format?', ensureAuthenticated, NotebooksController.remove_member)
app.get('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.show)
app.post('/notebooks.:format?', ensureAuthenticated, NotebooksController.create)
app.put('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.update)
app.delete('/notebooks/:id.:format?', ensureAuthenticated, NotebooksController.delete)

#
# Root
app.get '/', renderPublic, (req, res) ->
	res.redirect('/notes')