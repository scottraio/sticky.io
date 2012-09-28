render = require 'sticky-render'


exports.root = (req, res) ->
	if req.isAuthenticated()
		res.render('index', {domain:'test'})
	else
		res.render('public')

exports.index = (req, res) ->
	res.render('signup', {title: 'Sign-up to pine.io'})

exports.show = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, done

exports.edit = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, done

exports.create = (req, res) ->
	user = new app.models.User()
	user.set('name', req.body.name)
	user.set('email', req.body.email)
	user.set('password', req.body.password)

	user.save (err) ->
		if err
			console.log err
			res.redirect('/signup')
		else
			req.logIn user, (err) ->
				if err
					res.redirect('/login')
				else
					req.user.sendWelcomeEmail()
					req.user.registerXMPPBot()
					res.redirect('/')

#
# updates an user
#
exports.update = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, (err, note) ->

			console.log req.body

			if req.body.phone_number
				note.set 'phone_number', req.body.phone_number

			if req.body.password
				note.set 'password', req.body.password

			note.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, note)

exports.login = (req, res) ->
	res.render('login', {message: req.flash('error'), title: 'Login to pine.io'})

exports.logout = (req, res) ->
	req.logout()
	res.redirect('/')

exports.signup = (req, res) ->
	res.render('signup', {title: 'Sign-up to pine.io'})

exports.register = (req, res) ->
	req.user.registerXMPPBot()
	res.redirect('/')
