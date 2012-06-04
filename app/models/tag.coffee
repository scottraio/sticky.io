
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations'
Setter 		= require './setters'

TagSchema = new Schema()

mongoose.model('Tag', TagSchema)