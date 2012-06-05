helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User
Tag 	= app.models.Tag

#
# GET /tags.json
#
exports.index = (req,res) ->
	helpers.render_json req, res, (done) ->
		Note.tag_list {_user:req.user._id}, (err, dbres) ->
			if err 
				done(err)
			else
				if dbres.documents
					done(null, dbres.documents[0].results)

#
# GET /tags/reset.json
#
exports.reset = (req,res) ->	
	Note.where({}).desc('created_at').run (err, notes) ->
		for note in notes
			notes.tags = []
			
			note.save()
		res.redirect('/')
		

        
