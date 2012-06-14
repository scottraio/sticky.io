Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

TagsSchema = new Schema
	_id 		: { type: String }
	value		: { count: Number, _user: ObjectId }
	
	
mongoose.model('Tag', TagsSchema)