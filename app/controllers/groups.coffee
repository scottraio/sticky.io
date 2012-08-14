render 		= require 'sticky-render'
Note 			= app.models.Note
User 			= app.models.User
Group 		= app.models.Group
Notebook 	= app.models.Notebook

#
# returns a single group provided an ID
# GET /groups/:id.json
#
exports.show = (req,res) ->
	helpers.render_json req, res, (done) ->
		Group.findOne({_id:req.params.id, _users:req.user.id}).populate('_users').run(done)

#
# returns a single group provided an ID
# GET /groups/:id/notes.json
#
exports.notes = (req,res) ->
	helpers.render_json req, res, (done) ->
		Note.where('groups', req.params.id.toLowerCase()).where('_user', req.user.id).populate('_user').desc('created_at').run (err, notes) ->
			done(err, {notes: notes})

#
# lists all groups for an user in a neatly packed JSON array
# GET /groups.json
#
exports.index = (req, res) ->
	helpers.render_json req, res, (done) ->
		Notebook.update_index {_user:req.user.id}, () ->
			Notebook.find {"value._user":req.user.id}, done		
	
#
# creates a new group for an user
# POST /groups.json
#
exports.create = (req, res) ->
	helpers.render_json req, res, (done) ->
		# find all members 
		Group.with_members req, (members) ->

			# save the group
			group = new Group()
			group.set 'name', 			req.body.name
			group.set '_users', 		members
			group.set '_moderators', 	[req.user.id]
			group.set 'created_at', 	new Date()

			group.save (err) -> 
				if err
					console.log(err.errors)
					req.flash('error', 'Group could not be saved.')
					done(err)
				else
					done(null, group)

#
# updates an existing group
# PUT /groups/:id.json
#
exports.update = (req, res) ->
	helpers.render_json req, res, (done) ->
		console.log req.body

		Group.findOne {_id:req.params.id}, (err, group) ->
			# grab the CSV string from the body, remove white-space, then split the emails by 
			# a comma. 
			Group.with_members req, (members) ->
			
				group.set 'name', req.body.name
				group.set '_users', members
				group.save (err) -> 
					if err
						console.log(err)
						req.flash('error', 'Group could not be saved.')
						done(err)
					else
						done(null, group)

#
# grabs an group and returns its JSON
# GET /groups/:id/edit.json
#
exports.edit = (req, res) ->
	helpers.render_json req, res, (done) ->
		Group.findOne {_id:req.params.id}, done

#
# deletes an group from an account
# DELETE /groups/:id.json
#
exports.delete = (req, res) ->
	helpers.render_json req, res, (done) ->
		Group.remove {_id: req.params.id}, (err) ->
			done(err, {ok:true})



