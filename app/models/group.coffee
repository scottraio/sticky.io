Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

GroupsSchema = new Schema
	name  		: { type: String, required: true, trim: true}
	created_at	: { type: Date, required: true }
	_users 		: [{ type: ObjectId, ref: 'User' }]
	_moderators : [{ type: ObjectId, ref: 'User' }]

# Indexes
GroupsSchema.index { name: 1, _users: 1 }, { unique: true }

mongoose.model('Group', GroupsSchema)