Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId
regex 			= require 'sticky-regex'
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
	stacked_at	: { type: Date, default: null }
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
#
# Static Methods
NotesSchema.statics.create_note = (user,message,cb) ->
	# Setup the Note namespace
	Note = app.models.Note
	# find the last note that was saved. If it has been more than 5 minutes since the last note.
	# go ahead and save a new note. If this new note is being saved within that 5 min window, stack it
	# to the last note found.
	Note.last_note user, (last_note) ->

		note = new Note()
		note.set 'message', 		message
		note.set '_user', 			user._id
		note.set 'created_at', 	new Date()

		#
		# parse tags/links/groups into arrays
		note.parse()

		#
		# last note
		if last_note
			seconds_since_last_post = (new Date() - last_note.created_at) / 1000

		#
		# save note
		note.save (err) ->
			if err
				cb(err)
			else
				if last_note and seconds_since_last_post <= 300
					if note.groups.length > 0
						cb(null, note)
					else
						Note.stack {user:user, child_id:note._id, parent_id:last_note._id}, cb	
				else	
					cb(null, note)

NotesSchema.statics.last_note = (user, cb) ->
	app.models.Note.where('_user',user._id)
		.where('_parent', null)
		.limit(1)
		.sort('created_at', -1)
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
#
# Stacking
NotesSchema.statics.stack = (options, cb) ->
	app.models.Note.findOne {_id:options.child_id, _user:options.user}, (err, child) ->			
		app.models.Note.findOne {_id:options.parent_id, _user:options.user}, (err, parent) ->
			# assign child id to parent
			parent._notes.push child._id
			# assign parent to child
			child._parent 		= parent._id
			child.stacked_at 	= new Date()
			child.save (err) -> 
				unless err
					parent.save(cb)
				else
					cb(err, null)

#
#
# Parses all tags, links, and groups from message 
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
