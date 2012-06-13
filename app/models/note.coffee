
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

NotesSchema = new Schema
	message  	: { type: String, required: true, trim: true }
	tags		: { type: Array }
	links 		: { type: Array }
	created_at	: { type: Date, required: true }
	_user 		: { type: ObjectId, required: true, ref: 'User' } 

NotesSchema.methods.parse_tags = () ->
	self 		= @
	new_tags 	= []
	matches 	= this.message.match regex.match.tag

	if matches

		for tag in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			new_tags.push tag.substring(2)

	return @tags = new_tags

NotesSchema.methods.parse_links = () ->
	self = @

	matches = this.message.match regex.match.link

	if matches

		for link in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			self.links.push link

	return @links

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

	mongoose.connection.db.executeDbCommand command, (err, res) ->
		console.log res
		cb(err, res)


NotesSchema.statics.domain_list = (query,cb) ->
	Note = this

	map = () ->
		if !this.links
        	return
    
		for link in this.links
			regex 	= /((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/g
			pattern = regex.exec(link)
			if pattern
				domain 	= pattern[3]
			else
				domain  = null

			emit(link, {domain: domain, tags: this.tags})

	reduce = (key,values) ->
		return ""

	command =
		mapreduce	: "notes"
		map 		: map.toString()
		reduce 		: reduce.toString()
		query 		: query
		out 		: {inline: 1}

	mongoose.connection.db.executeDbCommand command, cb
		
	
mongoose.model('Note', NotesSchema)