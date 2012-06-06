
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require './validations'
Setter 		= require './setters'

NotesSchema = new Schema
	message  	: { type: String, required: true, trim: true }
	tags		: { type: Array }
	links 		: { type: Array }
	created_at	: { type: Date, required: true }
	_user 		: { type: ObjectId, required: true, ref: 'User' } 

NotesSchema.methods.parse_tags = () ->
	self = @
	tag_regex = /\s[#]+[A-Za-z0-9-_]+/g

	while ((tags = tag_regex.exec(this.message)) != null)
		console.log tags
		# strip tags down and add them to the array
		# e.g. #todo turns into todo
		self.tags.push tags[0].substring(2)

NotesSchema.methods.parse_links = () ->
	self = @
	link_regex = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g

	while ((links = link_regex.exec(this.message)) != null)
		self.links.push links[0]

NotesSchema.statics.tag_list = (query,cb) ->
	Note = this

	map = () ->
		if !this.tags
        	return
    
		for tag in this.tags
			emit(tag, 1)

	reduce = (key,values) ->
		count = 0
		for index in values
			count += values[index]

		return count

	command =
		mapreduce	: "notes"
		map 		: map.toString()
		reduce 		: reduce.toString()
		query 		: query
		out 		: {inline: 1}

	mongoose.connection.db.executeDbCommand command, cb


NotesSchema.statics.domain_list = (query,cb) ->
	Note = this

	map = () ->
		if !this.links
        	return
    
		for link in this.links
			emit(link, this)

	reduce = (key,note) ->
		return note.tags

	command =
		mapreduce	: "notes"
		map 		: map.toString()
		reduce 		: reduce.toString()
		query 		: query
		out 		: {inline: 1}

	mongoose.connection.db.executeDbCommand command, cb
		
	
mongoose.model('Note', NotesSchema)