helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User


#
# returns a single note provided an ID
# GET /notes/:id.json
#
exports.show = (req,res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne({_id:req.params.id, _user:req.user}).run(done)

#
# lists all notes for an user in a neatly packed JSON array
# GET /notes.json
#
exports.index = (req, res) ->
	helpers.render_json req, res, (done) ->
		note = Note.where('_user', req.user)

		# Filter by keyword
		if req.query.keyword
			note.where('message', new RegExp(req.query.keyword))
		# Filter by tags
		if req.query.tags
			note.where('tags').in(req.query.tags) 
		# From a specific time period
		if req.query.days
			today 	= new Date()
			start 	= new Date().setDate(today.getDate() - req.query.days)
			note.where('created_at').equals({$gte: new Date(start), $lt: today})
	
		note.desc('created_at').run(done)
	

#
# creates a new note for an user
# Important: the post data must contain a title and array of book IDs 
#
exports.create = (req, res) ->
	helpers.render_json req, res, (done) ->
		note = new Note()
		note.set 'message', 	req.body.message
		note.set '_user', 		req.user._id
		note.set 'created_at', 	new Date()

		#
		# parse tags/links/groups into arrays
		note.parse()

		note.save (err) -> 
			if err
				console.log(err)
				req.flash('error', 'Note could not be saved.')
				done(err)
			else
				done(null, note)

#
# updates an existing note for an user
#
exports.update = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->
			note.set 'message', req.body.message
			
			#
			# parse tags into note.tags
			note.parse_tags()
			#
			# parse links into note.links
			note.parse_links()

			note.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, note)

#
# grabs an note and returns its JSON
#
exports.edit = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne {_id:req.params.id, _user:req.user}, done

#
# deletes an note from an account
#
exports.delete = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.remove {_id: req.params.id, _user:req.user}, (err) ->
			done(err, {ok:true})



