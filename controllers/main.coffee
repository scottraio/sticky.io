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

app.get('/databases', ensureAuthenticated, DatabasesController.root)
app.get('/databases/new', ensureAuthenticated, DatabasesController.root)
app.get('/databases/:id/edit', ensureAuthenticated, DatabasesController.root)
app.post('/databases', ensureAuthenticated, DatabasesController.create)


#
# Root
#

app.get('/', UsersController.root)
app.get('/docs', (req, res) -> res.render('docs', {title: 'pine.io documentation'}) )
