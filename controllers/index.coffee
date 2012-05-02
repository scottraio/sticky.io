#
#
# Controllers Main - Hybrid application_controller/routes
#
#
fs 					= require 'fs'
passport 			= require '../lib/passport'
Resource			= require '../lib/express_resource'
TablesController 	= require './tables'
DatabasesController = require './databases'
UsersController		= require './users'
RecordsController	= require './records'

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
app.get('/databases/:id.:format?', ensureAuthenticated, DatabasesController.show)
app.get('/databases/new', ensureAuthenticated, DatabasesController.root)
app.get('/databases/:id/edit', ensureAuthenticated, DatabasesController.root)
app.post('/databases', ensureAuthenticated, DatabasesController.create)

# 
# Tables
#

app.get('/:database_id/tables.:format?', ensureAuthenticated, TablesController.root)
app.get('/:database_id/tables/:id.:format?', ensureAuthenticated, TablesController.show)
app.get('/:database_id/tables/new', ensureAuthenticated, TablesController.root)
app.get('/:database_id/tables/:id/edit', ensureAuthenticated, TablesController.root)
app.post('/:database_id/tables', ensureAuthenticated, TablesController.create)

#
# Records
#

app.get('/:database_id/:table_id/records.:format?', ensureAuthenticated, RecordsController.show)
app.get('/:database_id/:table_id/records/:id.:format?', ensureAuthenticated, RecordsController.show)
app.get('/:database_id/:table_id/records/new', ensureAuthenticated, RecordsController.root)
app.get('/:database_id/:table_id/records/:id/edit', ensureAuthenticated, RecordsController.root)
app.post('/:database_id/:table_id/records', ensureAuthenticated, RecordsController.create)


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
