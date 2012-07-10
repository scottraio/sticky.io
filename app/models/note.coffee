Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
regex 		= require '../../lib/regex'
Validations = require './validations'
Setter 		= require './setters'

NotesSchema = new Schema
	message  	: { type: String, required: true, trim: true }
	color  		: { type: String, trim: true, default: null }
	tags		: { type: Array, default: [] }
	links 		: { type: Array, default: [] }
	groups 		: { type: Array, default: [] }
	created_at	: { type: Date, required: true }
	_user 		: { type: ObjectId, required: true, ref: 'User' } 
	_parent		: { type: ObjectId, ref: 'Note' }
	_notes 		: [ { type: ObjectId, ref: 'Note' } ]

# Indexes
NotesSchema.index { created_at:-1, tags: 1,  _user: 1 }
NotesSchema.index { created_at:-1 }
NotesSchema.index { _user:1 }

NotesSchema.statics.note_and_parent = (req, cb) ->
	app.models.Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->			
		app.models.Note.findOne {_id:req.params.parent_id, _user:req.user}, (err, parent) ->
			cb(note,parent)

NotesSchema.statics.from_note_to_note = (req, cb) ->
	app.models.Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->
		app.models.Note.findOne {_id:req.params.from_id, _user:req.user}, (err, from) ->		
			app.models.Note.findOne {_id:req.params.to_id, _user:req.user}, (err, to) ->
				cb(note,from,to)


# Parses all tags, links, and groups from message 
NotesSchema.methods.parse = () ->
	@parse_tags()
	@parse_links()
	@parse_groups()

NotesSchema.methods.parse_tags = () ->
	self 		= @
	new_tags 	= []
	matches 	= @message.match regex.match.tag

	if matches

		for tag in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			new_tags.push tag.replace(/#/, '').replace(/\s/, '')

	return @tags = new_tags

NotesSchema.methods.parse_links = () ->
	self 		= @
	new_links 	= []
	matches 	= @message.match regex.match.link

	if matches

		for link in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			new_links.push link

	return @links = new_links

NotesSchema.methods.parse_groups = () ->
	self = @

	matches = @message.match regex.match.group

	if matches

		for group in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			self.groups.push group.replace(/@/, '').replace(/\s/, '').toLowerCase()

	return @groups


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

			emit(link, {domain: domain, tags: this.tags, created_at: this.created_at})

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