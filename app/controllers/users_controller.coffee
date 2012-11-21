render 	= require 'sticky-render'

makeid = () ->
	text = "";
	possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	for num in [1..5]
		text += possible.charAt(Math.floor(Math.random() * possible.length))
	return text

exports.root = (req, res) ->
	if req.isAuthenticated()
		res.render('index', {domain:'test'})
	else
		res.render('public')

exports.index = (req, res) ->
	res.render('signup', {title: 'Sign-up to Sticky'})

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
# PUT /users/:id[.json]
exports.update = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, (err, user) ->

			if req.body.password
				user.set 'password', req.body.password

			if req.body.theme
				user.set 'theme', req.body.theme

			user.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, user)

#
# Confirm Phone Number
# GET /users/:id/confirm_phone
exports.confirm_phone_number = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, (err, user) ->
			user.set 'phone_number_confirm_token', makeid()
			user.save (err) -> 
				if err
					console.log(err)
					done(err)
				else
					req.user.confirmPhoneNumber(req.body.phone_number, user.phone_number_confirm_token)
					done(null, user)

#
# Confirm Phone Number
# GET /users/:id/confirm_phone
exports.auth_phone_number = (req, res) ->
	render.json req, res, (done) ->
		app.models.User.findOne {_id:req.user._id}, (err, user) ->
			
			if user.phone_number_confirm_token is req.body.phone_number_confirm_token and req.body.phone_number isnt null
				user.set 'phone_number', user.valid_phone_number(req.body.phone_number)
				user.set 'phone_number_confirm_at', new Date()

			user.save (err) -> 
				if err
					console.log(err)
					done(err)
				else
					done(null, user)

#
# Re-register the XMPP Bot
# GET /welcome
exports.welcome = (req, res) ->
	render.render_page 'welcome', req, res

#
# Login user
# GET /login
exports.login = (req, res) ->
	res.render('login', {message: req.flash('error'), title: 'Login to Sticky'})

#
# Logout user
# GET /logout
exports.logout = (req, res) ->
	req.logout()
	res.redirect('/')

#
# Signup user
# GET /signup
exports.signup = (req, res) ->
	res.render('signup')

#
# Re-register the XMPP Bot
# GET /register
exports.register = (req, res) ->
	req.user.registerXMPPBot()
	res.redirect('/')
