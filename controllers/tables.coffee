#
#
# Table Controller
#
#

helpers 	= require './helpers'
Table 		= app.models.Table
Database 	= app.models.Database

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		# Get the database 
		get_database req, (err, database) ->
			if database
				Table.find {database_id:database._id, user_id:req.user._id}, done
			else
				done(err, [])

exports.show = (req, res) ->
	helpers.render_json req, res, (done) ->
		Table.findOne {_id:req.params.id}, done
	
exports.create = (req, res) ->
	# Get the database
	get_database req, (err, database) ->
		table = new Table()

		table.set 'title', 			req.body.title
		table.set 'user_id', 		req.user._id
		table.set 'database_id', 	database._id

		table.save (err) ->
			if err
				console.log(err)
				req.flash('error', 'Table could not be saved.')
				res.redirect("/#{req.params.database_id}/tables/new")
			else
				res.redirect("/#{req.params.database_id}/tables")

get_database = (req, cb) ->
	options = {
		database_id : req.params.database_id
		user_id		: req.user._id
	}

	Database.get(options, cb)

