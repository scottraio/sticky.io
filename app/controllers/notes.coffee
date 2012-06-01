helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User


#
# returns a single note provided an ID
# GET /notes/:id.json
#
exports.show = (req,res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne({_id:req.params.id}).run(done)

#
# lists all notes for an account in a neatly packed JSON array
# GET /notes.json
#
exports.index = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.find({_account:req.user._account}).run(done)

#
# creates a new note for an account
# Important: the post data must contain a title and array of book IDs 
#
exports.create = (req, res) ->
	helpers.render_json req, res, (done) ->
		new_note = new Note()
		new_note.set 'title', 		req.body.title
		new_note.set '_books', 		req.body.books
		new_note.set '_creator', 	req.user._id
		new_note.set '_modifier', 	req.user._id
		new_note.set '_account', 	req.user._account

		new_note.save (err) -> 
			if err
				console.log(err)
				req.flash('error', 'Note could not be saved.')
				done(err)
			else
				done(null, new_note)

#
# updates an existing note for an account
# Important: the post data must contain a title and array of book IDs 
#
exports.update = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne {_id:req.params.id}, (err, exs_note) ->
			exs_note.set 'title', 		req.body.title
			exs_note.set 'updated_at', 	new Date()
			exs_note.set '_books', 		req.body.books
			exs_note.set '_modifier', 	req.user._id

			exs_note.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, exs_note)

#
# grabs an note and returns its JSON
# Important: does not populate the JSON package with _books, its just the data
#
exports.edit = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.findOne {_id:req.params.id}, done

#
# deletes an note from an account
#
exports.delete = (req, res) ->
	helpers.render_json req, res, (done) ->
		Note.remove {_id: req.params.id}, (err) ->
			done(err, {ok:true})