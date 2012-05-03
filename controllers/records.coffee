#
#
# Table Controller
#
#

helpers 	= require './helpers'
Database 	= app.models.Database
Table 		= app.models.Table
Record 		= app.models.Record

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		options = {
			database_id : req.params.database_id
			table_id 	: req.params.table_id
			user_id		: req.user._id
		}

		Record.find_with_collection(options,done)

exports.show = (req, res) ->
	helpers.render_json req, res, (done) ->
		Record.findOne {_id:req.params.id}, done
	
exports.create = (req, res) ->
	options = {
		database_id : req.params.database_id
		table_id 	: req.params.table_id
		user_id		: req.user._id
		data 		: req.body.data
	}

	Record.create options, (err, redirect) ->
		if err
			console.log(err)
			req.flash('error', 'Record could not be saved.')
			res.redirect(redirect)
		else
			res.redirect(redirect)

exports.delete = (req, res) ->
	options = {
		database_id : req.params.database_id
		table_id 	: req.params.table_id
		user_id		: req.user._id
		_id 		: req.params.id
	}

	Table.get options, (err, table) ->
		Record.delete options, (err) ->
			res.redirect("/#{options.database_id}/#{options.table_id}/records")

	
		

	

	