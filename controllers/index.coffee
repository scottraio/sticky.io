#
#
# Controllers Main - Hybrid application_controller/routes
#
#
fs 					= require 'fs'
passport 			= require '../lib/passport'
Resource			= require '../lib/express_resource'
UsersController 	= require './users'
DatabasesController = require './databases'
UsersController = require './users'

ensureAuthenticated = (req, res, next) ->
	return next() if req.isAuthenticated()
	switch req.params.format 
		when 'json' 
			passport.authenticate('basic',{session:false})(req, res, next)

		else res.redirect('/login')

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
# Database
#

app.get('/databases.:format?', ensureAuthenticated, DatabasesController.root)
app.get('/databases/new', ensureAuthenticated, DatabasesController.root)
app.get('/databases/:id/edit', ensureAuthenticated, DatabasesController.root)
app.post('/databases', ensureAuthenticated, DatabasesController.create)


#
# Root
#
app.get '/', UsersController.root

#
# Docs
#

app.get '/docs', (req, res) -> 
	fs.readFile "./docs/index.html", 'utf-8', (err, data) ->
		res.render('docs', {doc: data})

app.get '/docs/:title', (req, res) -> 
	fs.readFile "./docs/#{req.params.title}", 'utf-8', (err, data) ->
		res.render('docs', {doc: data})
