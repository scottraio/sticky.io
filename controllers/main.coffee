passport 		= require '../lib/passport'
UsersController = require './users'

ensureAuthenticated = (req, res, next) ->
	return next() if req.isAuthenticated()
	res.redirect('/login')

app.get('/login', UsersController.login)
app.post('/login', passport.authenticate('local', { successRedirect: '/', failureRedirect: '/login' }))

app.get('/signup', UsersController.signup)
app.post('/signup', UsersController.create)

app.get('/', ensureAuthenticated, UsersController.root)
