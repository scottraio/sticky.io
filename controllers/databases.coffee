#
#
# Users Controller
#
#

exports.root = (req, res) ->
	res.render('index', {title: 'Welcome to pine.io'})

exports.create = (req, res) ->
	db = new app.models.Database()

	db.set('title', req.body.title)
	db.set('user_id', 1)

	db.save (err) ->
		if err
			res.redirect('/databases/new')
		else
			res.redirect('/databases/')