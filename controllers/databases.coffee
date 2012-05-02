#
#
# Database Controller
#
#

helpers = require './helpers'
Database = app.models.Database

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		Database.find {user_id:req.user._id}, done

exports.show = (req, res) ->
	helpers.render_json req, res, (done) ->
		Database.findOne {_id:req.params.id}, done
	
exports.create = (req, res) ->
	db = new Database()
	db.set('title', req.body.title)
	db.set('user_id', req.user._id)

	db.save (err) ->
		if err
			req.flash('error', 'Database could not be saved.')
			res.redirect('/databases/new')
		else
			res.redirect('/databases')