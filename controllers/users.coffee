#
#
# Users Controller
#
#

exports.root = (req, res) ->
	if req.isAuthenticated()
		res.render('index')
	else
		res.render('public')

exports.index = (req, res) ->
	res.render('signup', {title: 'Sign-up to pine.io'})

exports.create = (req, res) ->
	user = new app.models.User()

	user.set('name', req.body.name)
	user.set('email', req.body.email)
	user.set('password', req.body.password)

	user.save (err) ->
		if err
			res.redirect('/signup')
		else
			req.logIn user, (err) ->
				return res.redirect('/login') if err
				res.redirect('/')

exports.login = (req, res) ->
	res.render('login', {message: req.flash('error'), title: 'Login to pine.io'})

exports.logout = (req, res) ->
	req.logout()
	res.redirect('/login')

exports.signup = (req, res) ->
	res.render('signup', {title: 'Sign-up to pine.io'})