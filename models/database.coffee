Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')


DatabaseSchema = new Schema
					title  	 : { type: String, required: true, trim: true }
					user_id	 : { type: Number, required: true, trim: true, unique: true, lowercase: true }


DatabaseSchema.path('title').validate Validations.cannotBeEmpty, 'title'
DatabaseSchema.path('user_id').validate Validations.cannotBeEmpty, 'user_id'


mongoose.model('Database', DatabaseSchema)