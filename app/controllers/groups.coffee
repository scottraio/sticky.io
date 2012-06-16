helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User
Group 	= app.models.Group

#
# returns a single group provided an ID
# GET /groups/:id.json
#
exports.show = (req,res) ->
	helpers.render_json req, res, (done) ->
		Group.findOne({name:req.params.id, _users:req.user.id}).run (err, group) ->
			if group
				Note.where('_user', req.user).where('groups', group.name).populate('_user').desc('created_at').run (err, notes) ->
					done(err, {notes: notes, group: group})
			else
				done(err, {})

#
# lists all groups for an user in a neatly packed JSON array
# GET /groups.json
#
exports.index = (req, res) ->
	helpers.render_json req, res, (done) ->
		Group.find({_id:req.params.id}).run(done)		
	
#
# creates a new group for an user
# POST /groups.json
#
exports.create = (req, res) ->
	helpers.render_json req, res, (done) ->
		# find all members 
		User.find({}).where('email').in(req.body.members).where('_id').ne(req.user.id).run (err, users) ->
			# load the creator as the initial member
			members = [req.user.id]
			# build the members list
			for user in users
				members.push user._id
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
		Group.findOne {_id:req.params.id}, (err, group) ->
			group.set 'name', req.body.name
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



