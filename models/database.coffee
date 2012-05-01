Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'

db 			= mongoose.connection

DatabaseSchema = new Schema {
	title  	 	: { type: String, required: true, trim: true }
	user_id	 	: { type: Number, required: true}
}

#
# Database Methods
#

DatabaseSchema.pre 'save', (next) ->
	collection = new mongoose.Collection('test123', db)
	collection.insert {ok: true}, {safe:true}, (err, objects) ->
		console.log(err) if (err)
	next()


mongoose.model('Database', DatabaseSchema)