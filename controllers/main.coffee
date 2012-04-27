#
#
# Controllers Main - Hybrid application_controller/routes
#
#

passport 			= require '../lib/passport'
UsersController 	= require './users'
DatabasesController = require './databases'

ensureAuthenticated = (req, res, next) ->
	return next() if req.isAuthenticated()
	res.redirect('/login')

#
# Authentication
# 

app.get('/login', UsersController.login)
app.post('/login', passport.authenticate('local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true }))
app.get('/logout', UsersController.logout)
app.get('/signup', UsersController.signup)
app.post('/signup', UsersController.create)

#
# Database
#

app.get('/databases', DatabasesController.root)
app.get('/databases/new', DatabasesController.root)
app.get('/databases/:id/edit', DatabasesController.root)
app.post('/databases', DatabasesController.create)


#
# Root
#

app.get('/', ensureAuthenticated, UsersController.root)
