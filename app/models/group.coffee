Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId
regex 			= require 'sticky-regex'
Validations = require './validations'
Setter 			= require './setters'

GroupsSchema = new Schema
	name  		: { type: String, required: true, trim: true}
	created_at	: { type: Date, required: true }
	_users 		: [{ type: ObjectId, ref: 'User' }]
	_moderators : [{ type: ObjectId, ref: 'User' }]

# Indexes
GroupsSchema.index { name: 1, _users: 1 }, { unique: true }


GroupsSchema.statics.with_members = (req, cb) ->
	emails = req.body.members.replace(' ', '').split(',')
	# Find all new member canidates
	app.models.User.find({}).where('email').in(emails).where('_id').ne(req.user.id).run (err, users) ->

		# load the creator as the initial member
		members = [req.user.id]
		# build the members list
		for user in users
			members.push user._id

		cb(members)

mongoose.model('Group', GroupsSchema)
