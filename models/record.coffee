Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')


RecordSchema = new Schema
				database_id  	: { type: String, required: true, trim: true }
				user_id	 		: { type: Number, required: true, trim: true, unique: true, lowercase: true }


RecordSchema.path('title').validate Validations.cannotBeEmpty, 'title'
RecordSchema.path('user_id').validate Validations.cannotBeEmpty, 'user_id'


mongoose.model('Database', RecordSchema)

#
# Record Methods
#
#