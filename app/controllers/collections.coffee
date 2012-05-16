#
#
# Collection Controller
#
#

helpers 	= require './helpers'
Collection 	= app.models.Collection
Database 	= app.models.Database

exports.root = (req, res) ->
	helpers.render_json req, res, (done) ->
		# Get the database 
		get_database req, (err, database) ->
			if database
				Collection.find {database_id:database._id, user_id:req.user._id}, done
			else
				done(err, [])

exports.show = (req, res) ->
	helpers.render_json req, res, (done) ->
		Collection.findOne {_id:req.params.id}, done
	
exports.create = (req, res) ->
	# Get the database
	get_database req, (err, database) ->
		collection = new Collection()

		collection.set 'title', 			req.body.title
		collection.set 'user_id', 		req.user._id
		collection.set 'database_id', 	database._id

		collection.save (err) -> 
			if err
				console.log(err)
				req.flash('error', 'Collection could not be saved.')
				res.redirect("/#{req.params.database_id}/collections/new")
			else
				res.redirect("/#{req.params.database_id}/collections")

exports.delete = (req, res) ->
	get_database req, (err, database) ->
		Collection.remove {_id: req.params.id}, (err) ->
			res.redirect("/#{req.params.database_id}/collections")			

get_database = (req, cb) ->
	options = {
		database_id : req.params.database_id
		user_id		: req.user._id
	}

	Database.get(options, cb)

