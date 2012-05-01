Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'

db 			= mongoose.connection

DatabaseSchema = new Schema {
	title  	 	: { type: String, required: true, uniq: true, trim: true }
	user_id	 	: { type: ObjectId, required: true}
}

#
# Database Methods
#

DatabaseSchema.pre 'save', (next) ->
	collection = new mongoose.Collection(this.title, db)
	collection.insert {ok: true}, {safe:true}, (err, objects) ->
		console.log(err) if (err)
	next()


mongoose.model('Database', DatabaseSchema)