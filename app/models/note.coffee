
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations'
Setter 		= require './setters'

NotesSchema = new Schema
	message  	: { type: String, required: true, trim: true }
	created_at	: { type: Date, required: true }
	_user 		: { type: ObjectId, required: true, ref: 'User' }

mongoose.model('Note', NotesSchema)