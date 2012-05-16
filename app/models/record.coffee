_ 				= require('underscore')
Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId
Validations 	= require('./validations.coffee')
Database 		= mongoose.models.Database
Collection 		= mongoose.models.Collection

RecordSchema = new Schema(
	collection_id  	: { type: ObjectId, required: true, trim: true }
	user_id	 		: { type: ObjectId, required: true, trim: true }
	data	 		: { type: Array, required: true }
)

#
# Validations
#

#RecordSchema.path('data').validate(Validations.validJSON, 'data')

# 
# Callbacks
#

RecordSchema.pre 'save', (next) ->
	next()

#
# Record Methods
#


RecordSchema.methods.set_collection = (title) ->
	this.collection = mongoose.connection.collection(title)

RecordSchema.statics.find_with_collection = (options, cb) ->
	Record = this

	Collection.get options, (err, collection) ->
		if collection
			query = Record.query(options.database_id)
			
			query.where('collection_id', collection._id)
			query.where('user_id', options.user_id)

			query.exec(cb)
		else
			cb(err)

RecordSchema.statics.create = (options, cb) ->
	Record = this 

	Collection.get options, (err, collection) ->
		if collection
			record = new Record
				user_id 		: options.user_id
				collection_id 	: collection._id
			
			# TODO: Risky threat to collection names
			# My reasoning is that we can trust that if we find a valid collection, then the 
			# database title is also the same. 
			record.set_collection(options.database_id)

			# Preformat the data into an array of hashes
			record.formatted_data(options.data)		
	
			record.save (err) ->
				if err
					cb(err, "/#{options.database_id}/#{collection.title}/records/new")
				else
					cb(null, "/#{options.database_id}/#{collection.title}/records")
			
		else
			cb(err, "/#{options.database_id}/collections/new")

RecordSchema.methods.formatted_data = (raw) ->
	bucket 	= []
	json 	= JSON.parse(raw)
	keys 	= _.keys(json)

	for key in keys
		dict 		= {}
		val 		= json[key]
		dict[key] 	= val
		bucket.push dict

	@data = bucket


RecordSchema.statics.delete = (options, cb) ->
	Record = this
	
	Collection.get options, (err, collection) ->
		if collection
			query = Record.query(options.database_id)
		
			query.where('collection_id', collection._id)
			query.where('user_id', options.user_id)
			query.where('_id', options._id)
			
			query.remove(cb)
		else
			cb(err)
	
RecordSchema.statics.query = (db_title) ->
	query = this.find {}

	# WARNING: Namepace Confusion
	# when the namespace 'collection' is being used for the following
	# two lines. It implies MongoDB collection, not Pine.io/Mongoose 'Collection'
	query.model.collection.name 						= db_title
	query.model.collection.collection.collectionName 	= db_title
	return query




mongoose.model('Record', RecordSchema)
