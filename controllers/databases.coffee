#
#
# Database Controller
#
#

exports.root = (req, res) ->
	switch req.params.format
		when 'json'
			app.models.Database.find {}, (err, dbs) ->
				res.writeHead 200, 'Content-Type': 'application/json'
				res.end JSON.stringify(dbs)

		else res.render('index')
			

exports.create = (req, res) ->
	db = new app.models.Database()
	db.set('title', req.body.title)
	db.set('user_id', 1)

	db.save (err) ->
		if err
			res.redirect('/databases/new')
		else
			res.redirect('/databases')