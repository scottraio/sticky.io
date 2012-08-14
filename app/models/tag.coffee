Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId
regex 			= require 'sticky-regex'
Validations = require './validations'
Setter 			= require './setters'

TagsSchema = new Schema
	_id 		: { type: String }
	value		: { count: Number, _user: ObjectId }


TagsSchema.statics.update_index = (options, cb) ->
	map = () ->
		if !this.tags
        	return
    
		for tag in this.tags
			emit(tag, {count:1, _user:this._user})

	reduce = (key,values) ->
		result = {count: 0, _user: values._user}

		values.forEach (val) ->
			result._user = val._user
			result.count += val.count

		return result

	command =
		mapreduce	: "notes"
		map 			: map.toString()
		reduce 		: reduce.toString()
		out 			: "tags"

	mongoose.connection.db.executeDbCommand command, (err, res) ->
		cb()
	
mongoose.model('Tag', TagsSchema)
