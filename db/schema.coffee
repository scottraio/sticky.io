module.exports = 
   

	users: (Schema) -> 
		new Schema
			name 		: { type: String }
			email 		: { type: String }
			password 	: { type: String }

	databases: (Schema) -> 
		new Schema
			title 	: { type: String }
			user_id : { type: Schema.ObjectId }

	fields: (Schema) -> 
		new Schema
			title		: { type: String }
			type		: { type: Number }
			database_id	: { type: Schema.ObjectId }

	records: (Schema) ->
		new Schema 
			data 		: {type: Array}
			user_id 	: {type: Schema.ObjectId}
			database_id : {type: Schema.ObjectId}
