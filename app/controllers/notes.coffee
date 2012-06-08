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
	if req.isAuthenticated()
		helpers.render_json req, res, (done) ->
			if req.query.tags
				Note.where('_user', req.user).where('tags').in(req.query.tags).desc('created_at').run(done)
			else
				Note.where('_user', req.user).desc('created_at').run(done)
	else
		res.render('public')

#
# lists all notes for an user based on tags in a neatly packed JSON array
# POST /
#
exports.filter = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.where('_user', req.user).where('tags').in(req.body.tags).desc('created_at').run(done)			
	

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
# updates an existing note for an user
#
exports.update = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->
			note.set 'message', req.body.message
	
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



