#
#
# Controllers Main - Hybrid application_controller/routes
#
#
fs 						= require 'fs'
passport 				= require '../../lib/passport'
Resource				= require '../../lib/express_resource'
CollectionsController 	= require './collections'
DatabasesController 	= require './databases'
UsersController			= require './users'
RecordsController		= require './records'

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
# Database
#

app.get('/databases.:format?', ensureAuthenticated, DatabasesController.root)
app.get('/databases/:id.:format?', ensureAuthenticated, DatabasesController.show)
app.get('/databases/new', ensureAuthenticated, DatabasesController.root)
app.get('/databases/:id/edit', ensureAuthenticated, DatabasesController.root)
app.post('/databases', ensureAuthenticated, DatabasesController.create)
app.delete('/databases/:id', DatabasesController.delete)
app.put('/databases/:id', DatabasesController.update)

# 
# Collections
#

app.get('/:database_id/collections.:format?', ensureAuthenticated, CollectionsController.root)
app.get('/:database_id/collections/:id.:format?', ensureAuthenticated, CollectionsController.show)
app.get('/:database_id/collections/new', ensureAuthenticated, CollectionsController.root)
app.get('/:database_id/collections/:id/edit', ensureAuthenticated, CollectionsController.root)
app.post('/:database_id/collections', ensureAuthenticated, CollectionsController.create)
app.delete('/:database_id/collections/:id', CollectionsController.delete)
app.put('/:database_id/collections/:id', CollectionsController.update)

#
# Records
#

app.get('/:database_id/:collection_id/records.:format?', ensureAuthenticated, RecordsController.root)
app.get('/:database_id/:collection_id/records/:id.:format?', ensureAuthenticated, RecordsController.show)
app.get('/:database_id/:collection_id/records/new', ensureAuthenticated, RecordsController.root)
app.get('/:database_id/:collection_id/records/:id/edit', ensureAuthenticated, RecordsController.root)
app.post('/:database_id/:collection_id/records', ensureAuthenticated, RecordsController.create)
app.delete('/:database_id/:collection_id/records/:id', RecordsController.delete)
app.put('/:database_id/:collection_id/records/:id', RecordsController.update)


#
# Root
#
app.get '/', UsersController.root

#
# Docs
#

app.get '/docs', (req, res) -> 
	fs.readFile "./docs/index.html", 'utf-8', (err, data) ->
		res.render('docs', {loggedIn:req.isAuthenticated(), doc: data})

app.get '/docs/:title', (req, res) -> 
	fs.readFile "./docs/#{req.params.title}", 'utf-8', (err, data) ->
		res.render('docs', {loggedIn:req.isAuthenticated(), doc: data})
