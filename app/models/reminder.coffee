Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

ReminderSchema = new Schema
	date		: { type: Date }
	_note		: { type: ObjectId, required: true, ref: 'Note' }
	_user 		: { type: ObjectId, required: true, ref: 'User' } 