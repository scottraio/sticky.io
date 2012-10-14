Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'

TagsSchema = new Schema
	_id 		: { type: String }
	value		: { count: Number, _user: Schema.ObjectId }


#
# Map/Reduce with mongoose https://gist.github.com/1123688
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
		#sort 			: {'_tags': 1}
		query			: {'_user':new mongoose.Types.ObjectId(options._user), 'deleted_at':null}
		out				: {inline: 1}
	
	mongoose.connection.db.executeDbCommand command, (err, res) ->

		# sort the map-reduced results on field_3
		sortedResults = res.documents[0].results.sort (current, next) ->
			return current.value._id - next.value._id

		# the final array
		finalGroupedResult = []
 
		# clean up the results returned by mapreduce
		sortedResults.forEach (obj, index) ->
			finalGroupedResult.push(obj)
	
		cb(finalGroupedResult)
	
mongoose.model('Tag', TagsSchema)
