Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')
Database 	= mongoose.models.Database
Table 		= mongoose.models.Table

RecordSchema = new Schema(
	database_id  	: { type: ObjectId, required: true, trim: true }
	table_id  		: { type: ObjectId, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true, trim: true }
	data	 		: { type: String, required: true }
)

RecordSchema.path('data').validate(Validations.validJSON, 'data')

#
# Record Methods
#

RecordSchema.methods.find_with_collection = (name, cb) ->
	collection = new mongoose.Collection(name, mongoose.connection)
	collection.find().toArray(cb)

RecordSchema.methods.set_collection = (title) ->
	this.collection = mongoose.connection.collection(title)

RecordSchema.statics.create = (req, res, cb) ->
	Record 			= this
	dbtitle 		= req.params.database_id
	tabletitle		= req.params.table_id

	Table.get dbtitle, tabletitle, req.user._id, (err, table) ->
		if table
			record = new Record
				data 		: req.body.data
				user_id 	: req.user._id
				database_id : table.database_id
				table_id 	: table._id
			
			record.set_collection(dbtitle)

			record.save (err) ->
				if err
					cb(err, "/#{dbtitle}/#{table.title}/records/new")
				else
					cb(null, "/#{dbtitle}/#{table.title}/records")
			
		else
			cb(err, "/#{dbtitle}/tables/new")
		


mongoose.model('Record', RecordSchema)
