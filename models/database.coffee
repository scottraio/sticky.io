Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'

db 			= mongoose.connection

DatabaseSchema = new Schema {
	title  	 	: { type: String, required: true, uniq: true, trim: true }
	user_id	 	: { type: ObjectId, required: true}
}

DatabaseSchema.path('title').validate Validations.titleFormat, 'title'

#
# Database Methods
#

DatabaseSchema.pre 'save', (next) ->
	collection = new mongoose.Collection(this.title, db)
	collection.insert {ok: true}, {safe:true}, (err, objects) ->
		console.log(err) if (err)
	next()

DatabaseSchema.statics.get = (options, cb) ->
	Database = this

	query = {
		title 	: options.database_id || options.title
		user_id	: options.user_id
	}

	Database.findOne(query, cb)


mongoose.model('Database', DatabaseSchema)