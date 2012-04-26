exports.root = (req, res) ->
	console.log("yay")
	res.render('index', {title: 'Welcome to pine.io'})

exports.index = (req, res) ->
	console.log("yay")
	res.render('signup', {title: 'Sign-up to pine.io'})

exports.create = (req, res) ->
	user = new app.models.User()

	user.set('name', req.body.name)
	user.set('email', req.body.email)
	user.set('password', req.body.password)

	user.save (err) ->
		if err
			console.log(err)
		else
			console.log('yay')
			#req.session.user = 
			#	id: user.get('id'),
			#	name: user.get('name')

			#req.session.auth = 
			#	logged_in: true,
			#	user_id: user.get('id')

	res.render('signup', {title: 'Sign-up to pine.io'})

exports.login = (req, res) ->
	res.render('login', {title: 'Login to pine.io'})
	#document = {name: "Scott", login: "scottraio@gmail.com"}
	#res.send JSON.stringify(document)

exports.signup = (req, res) ->
	res.render('signup', {title: 'Sign-up to pine.io'})