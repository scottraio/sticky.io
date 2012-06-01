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

#
# Users
#

app.get('/profile.:format?', ensureAuthenticated, UsersController.show)


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
# Root
#
app.get '/', NotesController.index

#
# Docs
#

app.get '/docs', (req, res) -> 
	fs.readFile "./docs/index.html", 'utf-8', (err, data) ->
		res.render('docs', {loggedIn:req.isAuthenticated(), doc: data})

app.get '/docs/:title', (req, res) -> 
	fs.readFile "./docs/#{req.params.title}", 'utf-8', (err, data) ->
		res.render('docs', {loggedIn:req.isAuthenticated(), doc: data})
