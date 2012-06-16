Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

GroupsSchema = new Schema
	name  		: { type: String, required: true, trim: true, unique: true }
	created_at	: { type: Date, required: true }
	_users 		: [{ type: ObjectId, ref: 'User' }]
	_moderators : [{ type: ObjectId, ref: 'User' }]

mongoose.model('Group', GroupsSchema)