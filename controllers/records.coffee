#
#
# Table Controller
#
#

helpers = require './helpers'
Record 	= app.models.Record

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		title = req.params.database_id
		Record.find _with_collection(title,done)
		

exports.show = (req, res) ->
	helpers.render_json req, res, (done) ->
		Record.findOne {_id:req.params.id}, done
	
exports.create = (req, res) ->
	Record.create req, res, (err, redirect) ->
		if err
			console.log(err)
			req.flash('error', 'Record could not be saved.')
			res.redirect(redirect)
		else
			res.redirect(redirect)

	
	

	