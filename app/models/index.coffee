#
# Invoke all models we need, expose mongoose
#


GLOBAL.mongoose = require 'mongoose'


mongoose.connect('mongodb://localhost/' + app.config.dbname)
mongoose.set('debug', true) if app.config.env is 'development'

require('./manifest')

mongoose.connection.on 'open', () ->

	#
	#
	# list of tags
	tags_map = () ->
		if !this.tags
        	return
    
		for tag in this.tags
			emit(tag, {count:1, _user:this._user})

	tags_reduce = (key,values) ->
		result = {count: 0, _user: values._user}

		values.forEach (val) ->
			result._user = val._user
			result.count += val.count

		return result

	tags_command =
		mapreduce	: "notes"
		map 		: tags_map.toString()
		reduce 		: tags_reduce.toString()
		query 		: {}
		out 		: "tags"

	mongoose.connection.db.executeDbCommand tags_command, (err, res) ->
		# finished


app.models		= mongoose.models
module.exports  = mongoose

