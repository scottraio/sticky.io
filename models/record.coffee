Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')
Database 	= mongoose.models.Database
Table 		= mongoose.models.Table

RecordSchema = new Schema(
	table_id  		: { type: ObjectId, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true, trim: true }
	data	 		: { type: String, required: true }
)

#
# Validations
#

RecordSchema.path('data').validate(Validations.validJSON, 'data')

#
# Record Methods
#

RecordSchema.statics.find_with_collection = (options, cb) ->
	Record = this

	Table.get options, (err, table) ->
		if table
			query = Record.query(options.database_id)
			
			query.where('table_id', table._id)
			query.where('user_id', options.user_id)
			
			query.exec(cb)
		else
			cb(err)

RecordSchema.statics.create = (options, cb) ->
	Record = this

	Table.get options, (err, table) ->
		if table
			record = new Record
				data 		: options.data
				user_id 	: options.user_id
				table_id 	: table._id
			
			# TODO: Risky threat to collection names
			# My reasoning is that we can trust that if we find a valid table, then the 
			# database title is also the same. 
			record.set_collection(options.database_id)

			record.save (err) ->
				if err
					cb(err, "/#{options.database_id}/#{table.title}/records/new")
				else
					cb(null, "/#{options.database_id}/#{table.title}/records")
			
		else
			cb(err, "/#{options.database_id}/tables/new")

RecordSchema.statics.delete = (options, cb) ->
	Record = this
	
	Table.get options, (err, table) ->
		if table
			query = Record.query(options.database_id)
		
			query.where('table_id', table._id)
			query.where('user_id', options.user_id)
			query.where('_id', options._id)
			
			query.remove(cb)
		else
			cb(err)
	
RecordSchema.statics.query = (db_title) ->
	query = this.find {}
	query.model.collection.name 						= db_title
	query.model.collection.collection.collectionName 	= db_title
	return query


RecordSchema.methods.set_collection = (title) ->
	this.collection = mongoose.connection.collection(title)


mongoose.model('Record', RecordSchema)
