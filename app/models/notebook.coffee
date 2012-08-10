Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

NotebookSchema = new Schema
	_id 		: { type: String }
	value		: { count: Number, _user: ObjectId }


NotebookSchema.statics.update_index = (options, cb) ->
	map = () ->
		if !this.groups
        	return

		for group in this.groups
			emit(group, {count:1, _user:this._user})

	reduce = (key,values) ->
		result = {count: 0, _user: values._user}

		values.forEach (val) ->
			result._user = val._user
			result.count += val.count

		return result

	command =
		mapreduce	: "notes"
		map 		  : map.toString()
		reduce 		: reduce.toString()
		out 		  : "notebooks"

	mongoose.connection.db.executeDbCommand command, (err, res) ->
		console.log err
		console.log res
		cb()
	
mongoose.model('Notebook', NotebookSchema)
