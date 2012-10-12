_ 			= require 'underscore'
render 	= require 'sticky-render'
Note 		= app.models.Note
User 		= app.models.User

#
# returns a single note provided an ID
# GET /notes/:id.json
#
exports.expanded = (req,res) ->
	render.json req, res, (done) ->
		Note.where('_user', req.user._id)
			.or([{'_id': req.params.id},{'_parent':req.params.id}])
			.populate('_domains')
			.run(done)

#
# lists all notes for an user in a neatly packed JSON array
# GET /notes.json
#
exports.index = (req, res) ->
	render.json req, res, (done) ->
		note = Note.where('_user', req.user).where('deleted_at', null)

		#
		# Filter by keyword
		if req.query.keyword
			note.where('message', new RegExp(req.query.keyword))
		
		#
		# Filter by tags
		if req.query.tags
			note.where('tags').in([req.query.tags]) 
		
		#
		# Filter by notebooks
		if req.query.notebooks
			note.where('groups').in([req.query.notebooks]) 
		
		#
		# Are we querying based off criteria?
		criteria = true unless _.isEmpty(req.query.tags) and _.isEmpty(req.query.notebooks) and _.isEmpty(req.query.keyword)

		#
		# From a specific time period
		today					= new Date()
		yesterday 		= new Date(new Date().setDate(today.getDate() - 1))
		threedaysago  = new Date(new Date().setDate(today.getDate() - 3))

		if req.query.start
			start = new Date(req.query.start)
			end 	= new Date(req.query.end)

			note.where('created_at').equals({$gte: start, $lt: end})

		#
		# Only show root level elements unless we are querying
		if _.isEmpty(req.query.tags)		
			note.where('_parent', null)

		#
		# Populate domains for root level stickies
		note.populate('_domains')

		if req.query.order
			switch req.query.order
				when 'desc' then order=-1
				when 'asc' 	then order=1

			note.sort('created_at', order)
		else
			note.sort('created_at', -1)

		#
		# Pagination
		note.skip(req.query.page*25) if req.query.page
		note.limit(25)

		note.run (err, items) ->
			console.log err if err
			# Hack! - This func should be supported in some version of mongoose 3.x
			# https://github.com/LearnBoost/mongoose/issues/601
			Note.populate_stacks items, (err, notes) ->
				done(err, notes)
	

#
# creates a new note for an user
# Important: the post data must contain a title and array of book IDs 
#
exports.create = (req, res) ->
	render.json req, res, (done) ->
		Note.create_note req.user, req.body.message, (err,note) ->
			if err
				console.log(err)
				req.flash('error', 'Note could not be saved.')
				done(err)
			else
				done(null, note)

#
# creates a new note for an user through our E-mail gateway (postmark)
exports.smtp = (req, res) ->
	User.findOne {email: req.body.From}, (err, user) ->
		if user
			Note.create_note user, req.body.TextBody, (err,note) ->
				if err
					res.writeHead 500, 'Content-Type': 'application/json'
					res.write err
					res.end('\n')
				else
					res.writeHead 200, 'Content-Type': 'application/json'
					res.write "ok"
					res.end('\n')
		else
			res.writeHead 401, 'Content-Type': 'application/json'
			res.write "auth required"
			res.end('\n')
					
#
# updates an existing note for an user
#
exports.update = (req, res) ->
	render.json req, res, (done) ->
		Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->

			if req.body.message
				note.set 'message', 		req.body.message
				# parse tags/links/groups into arrays
				note.parse()

			if req.body.color
				note.set 'color', req.body.color	

			if req.body.completed
				note.set 'completed', req.body.completed

			note.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, note)

#
# Notes Tree - aka "stacks"
#

exports.stack = (req, res) ->
	render.json req, res, (done) ->
		Note.stack req.user, {child_id:req.params.child_id, parent_id:req.params.parent_id}, done
	
exports.unstack = (req, res) ->
	render.json req, res, (done) ->
		Note.unstack req.user, {child_id:req.params.child_id, parent_id:req.params.parent_id}, done

exports.restack = (req, res) ->
	render.json req, res, (done) ->
		Note.restack req.user, {child_id:req.params.child_id, old_id:req.params.old_id, parent_id:req.params.parent_id}, done
			

#
# grabs an note and returns its JSON
#
exports.show = (req, res) ->
	render.json req, res, (done) ->
		Note.findOne {_id:req.params.id, _user:req.user}, done

#
# deletes an note from an account
#
exports.delete = (req, res) ->
	render.json req, res, (done) ->
		#Note.remove {_id: req.params.id, _user:req.user}, (err) ->
		#	done(err, {ok:true})
		Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->
			note.set 'deleted_at', new Date()
			note.save (err) -> 
				if err
					console.log(err)
					req.flash('error', 'Note could not be saved.')
					done(err)
				else
					done(null, note)


#
#
# Postmark Hook (email-to-sticky)
exports.inbound = (req, res) ->
	mail = JSON.parse(req.body)
	User.findOne {email:mail.From}, (err, user) ->	
		Note.create_note req.user, mail.TextBody, (err,note) ->
			if err
				console.log(err)
				return false
			else
				return true
