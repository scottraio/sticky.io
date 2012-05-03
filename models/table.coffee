db 			= mongoose.connection
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'


TableSchema = new Schema {
	title  	 		: { type: String, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true }
	database_id	 	: { type: ObjectId, required: true }
}

TableSchema.path('title').validate Validations.titleFormat, 'title'

#
# Table Methods
#

TableSchema.pre 'save', (next) ->
	next()

TableSchema.statics.get = (options,cb) ->
	Table 			= this
	Database 		= mongoose.models.Database

	Database.get options, (err, database) ->
		if database
			query = {
				title 		: options.table_id || options.title
				user_id 	: options.user_id
				database_id	: database._id
			}

			Table.findOne query, (err, table) ->
				if table
					cb(err, table)
		else
			cb(err)
 

mongoose.model('Table', TableSchema)