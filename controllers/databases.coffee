#
#
# Database Controller
#
#

helpers = require './helpers'

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		app.models.Database.find {user_id:req.user._id}, done
	

exports.create = (req, res) ->
	db = new app.models.Database()
	db.set('title', req.body.title)
	db.set('user_id', req.user._id)

	db.save (err) ->
		if err
			console.log err
			req.flash('error', 'Database could not be saved.')
			res.redirect('/databases/new')
		else
			res.redirect('/databases')