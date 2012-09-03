_					= require 'underscore'
render 		= require 'sticky-render'
Note 			= app.models.Note
User 			= app.models.User
Notebook 	= app.models.Notebook

exports.accept_invite = (req, res) ->
	Notebook.findOne {'_id':req.params.id}, (err, notebook) ->
		if notebook && notebook._members
			for member in notebook._members
				if member._user._id is req.user._id
					notebook.set 'accepted_at', new Date
					notebook.save (err) ->		
						res.redirect('/')
		else
			res.redirect('/')

exports.remove_member = (req, res) ->
	render.json req, res, (done) ->
		Notebook.findOne {'_id':req.params.id}, (err, notebook) ->
			user_id = mongoose.Types.ObjectId(req.params.user_id)
			
			for member in notebook._members
				i = notebook._members.indexOf(member)
				notebook._members[i].remove() if member is user_id
				
			notebook.save (err) ->		
				done(null, {'ok':true})

exports.show = (req, res) ->
	render.json req, res, (done) ->
		Notebook.where('_id', req.params.id)
			.where('_owner', req.user)
			.limit(1)
			.run(done)

exports.create = (req, res) ->
	render.json req, res, (done) ->
		notebook = new Notebook()
		
		notebook.set '_owner', req.user
		notebook.set 'created_at', new Date()
		notebook.set 'name', req.body.name
		
		notebook.save (err,note) ->
			if err
				console.log(err)
				req.flash('error', 'Note could not be saved.')
				done(err)
			else
				done(null, note)

exports.update = (req, res) ->
	render.json req, res, (done) ->
		Notebook.findOne {'_owner':req.user._id, '_id': req.params.id}, (err, notebook) ->
			
			notebook.invite_new_members req.body.members, (members) ->	
				notebook._members.push members
				notebook.set 'name', req.body.name
				
				notebook.save (err,note) ->
					if err
						console.log(err)
						req.flash('error', 'Note could not be saved.')
						done(err)
					else
						done(null, note)
