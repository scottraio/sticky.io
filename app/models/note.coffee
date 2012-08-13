Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId
regex 			= require '../../lib/regex'
Validations = require './validations'
Setter 			= require './setters'

NotesSchema = new Schema
	message  		: { type: String, required: true, trim: true }
	color  			: { type: String, trim: true, default: null }
	completed 	: { type: Boolean, default: false }
	tags				: { type: Array, default: [] }
	links 			: { type: Array, default: [] }
	groups 			: { type: Array, default: [] }
	created_at	: { type: Date, required: true }
	_user 			: { type: ObjectId, required: true, ref: 'User' } 
	_parent			: { type: ObjectId, ref: 'Note' }
	_notes 			: [ { type: ObjectId, ref: 'Note' } ]

#
# Indexes
#
NotesSchema.index { created_at:-1, tags: 1,  _user: 1 }
NotesSchema.index { created_at:-1 }
NotesSchema.index { _user:1 }

#
# Static Methods
#
NotesSchema.statics.last_note = (user, cb) ->
	app.models.Note.where('_user',user._id)
		.where('_parent', null)
		.limit(1)
		.sort('created_by', -1)
		.run (err, last_note) ->
			cb(last_note[0])

NotesSchema.statics.note_and_parent = (req, cb) ->
	app.models.Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->			
		app.models.Note.findOne {_id:req.params.parent_id, _user:req.user}, (err, parent) ->
			cb(note,parent)

NotesSchema.statics.from_note_to_note = (req, cb) ->
	app.models.Note.findOne {_id:req.params.id, _user:req.user}, (err, note) ->
		app.models.Note.findOne {_id:req.params.from_id, _user:req.user}, (err, from) ->		
			app.models.Note.findOne {_id:req.params.to_id, _user:req.user}, (err, to) ->
				cb(note,from,to)

#
# Stacking
#
NotesSchema.statics.stack = (options, cb) ->
	app.models.Note.findOne {_id:options.child_id, _user:options.user}, (err, child) ->			
		app.models.Note.findOne {_id:options.parent_id, _user:options.user}, (err, parent) ->
			# magic
			parent._notes.push child._id
			child._parent = parent._id
				
			child.save (err) -> 
				unless err
					parent.save(cb)
				else
					cb(err, null)

#
# Parses all tags, links, and groups from message 
#
NotesSchema.methods.parse = () ->
	@parse_tags()
	@parse_links()
	@parse_groups()

#
# Parse tags i.e. #todo, #urgent, #cool-links
#
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

#
# Parse all links
#
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

#
# Parse Groups/Notebooks
#
NotesSchema.methods.parse_groups = () ->
	self = @

	matches = @message.match regex.match.group

	if matches

		for group in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			self.groups.push group.replace(/@/, '').replace(/\s/, '').toLowerCase()

	return @groups

#
# Map/Reduce
#
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
