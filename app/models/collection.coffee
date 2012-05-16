db 			= mongoose.connection
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'


CollectionSchema = new Schema {
	title  	 		: { type: String, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true }
	database_id	 	: { type: ObjectId, required: true }
}

CollectionSchema.path('title').validate Validations.titleFormat, 'title'

#
# Collection Methods
#

CollectionSchema.pre 'save', (next) ->
	next()

CollectionSchema.statics.get = (options,cb) ->
	Collection 			= this
	Database 		= mongoose.models.Database


	Database.get options, (err, database) ->
		if database
			query = {
				title 		: options.collection_id || options.title
				user_id 	: options.user_id
				database_id	: database._id
			}

			Collection.findOne query, cb
		else
			cb(err)
 

mongoose.model('Collection', CollectionSchema)