db 			= mongoose.connection
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations.coffee'


TableSchema = new Schema {
	title  	 		: { type: String, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true }
	database_id	 	: { type: ObjectId, required: true }
}

#
# Table Methods
#

TableSchema.pre 'save', (next) ->
	next()

TableSchema.statics.get = (dbtitle,title,user_id,cb) ->
	Table 			= this
	Database 		= mongoose.models.Database

	Database.get dbtitle, user_id, (err, database) ->
		if database
			Table.findOne {title:title,database_id:database._id, user_id:user_id}, (err, table) ->
				if table
					cb(err, table)
		else
			cb(err, database)
 

mongoose.model('Table', TableSchema)