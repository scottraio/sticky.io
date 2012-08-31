render 		= require 'sticky-render'
Note 			= app.models.Note
User 			= app.models.User
Notebook 	= app.models.Notebook


exports.show = (req, res) ->
	render.json req, res, (done) ->
		Notebook.findOne {_id:req.params.id, _owner:req.user}, done

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
	
			notebook.set 'name', req.body.name
			
			notebook.save (err,note) ->
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, note)
