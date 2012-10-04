$						= require 'jquery'
_						= require 'underscore'


Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'


NotesSchema = new Schema
	message  		: { type: String, required: true, trim: true }
	plain_txt  	: { type: String, required: true, trim: true, default: '' }
	color  			: { type: String, trim: true, default: null }
	completed 	: { type: Boolean, default: false }
	tags				: { type: Array, default: [] }
	links 			: { type: Array, default: [] }
	groups 			: { type: Array, default: [] }
	created_at	: { type: Date, required: true }
	stacked_at	: { type: Date, default: null }
	deleted_at	: { type: Date, default: null }
	_user 			: { type: Schema.ObjectId, required: true, ref: 'User' }
	_parent			: { type: Schema.ObjectId, ref: 'Note' }
	_notes 			: [ { type: Schema.ObjectId, ref: 'Note' } ]
	_domains		: [ { type: Schema.ObjectId, ref: 'Domain' } ]
	_sms_id			: [ { type: String, unique: true, default: null } ]

#
# Indexes
NotesSchema.index { created_at:-1, tags: 1,  _user: 1 }
NotesSchema.index { created_at:-1 }
NotesSchema.index { _user:1 }


#
# Static Methods
NotesSchema.statics.create_note = (user,message,cb) ->
	# Setup the Note namespace

	note = new app.models.Note()
	note.set 'message', 		message
	note.set '_user', 			user._id
	note.set 'created_at', 	new Date()

	#
	# parse tags/links/groups into arrays
	note.parse()

	#
	# save note
	note.save (err) ->
		unless err
			#
			# Mixpanel
			#app.mixpanel.people.increment(user._id, "$note_count")

			#
			# SocketIO
			socket_ids = socketbucket[user._id]
			if socket_ids
				for socket_id in socket_ids
					io.sockets.socket(socket_id).emit 'notes:add', note

			cb(null, note)
		else
			cb(err)

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

NotesSchema.statics.populate_stacks = (notes, cb) ->
	Note = app.models.Note
	# extract ids from each parent note
	subnote_ids = []
	for note in notes
		subnote_ids.push note._notes
	ids = _.flatten(subnote_ids)
	
	Note.where('_id').in(ids).populate('_domains').run (err, subnotes) ->
		for note in notes
			# convert to object so we can manipulate
			note.toObject()
			# populate the _notes accordingly
			for subnote in subnotes	
				index = note._notes.indexOf(subnote._id)
				note._notes[index] = subnote if index isnt -1
			# return the results for mapping
		cb(err, notes)


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
	@simplify()
	@parse_tags()
	@parse_links()
	@parse_groups()

NotesSchema.methods.simplify = () ->
	if /<(?:.|\n)*?>/gm.test(@message)
		@set 'plain_txt', $("<div>#{@message}</div>").text() # strip any html, and just store the plain text message
	else
		@set 'plain_txt', @message

#
# Parse tags i.e. #todo, #urgent, #cool-links
#
NotesSchema.methods.parse_tags = () ->
	self 			= @
	new_tags 	= []
	matches 	= @plain_txt.match regex.match.tag

	if matches

		for tag in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			new_tags.push tag.replace(/#/, '').replace(/\s/, '')

	return @tags = new_tags

#
# Parse all links
NotesSchema.methods.parse_links = () ->
	self 				= @
	matches 		= @plain_txt.match regex.match.link
	Domain			= app.models.Domain

	if matches	
		for link in matches
			domain = new Domain()
			domain.crawl link, self, (err, domain) ->
				console.log err if err
				if domain && self._domains.indexOf(domain._id) is -1
					self._domains.push domain._id
				self.save (err) ->
					console.log err if err
	else
		self._domains = []
		self.save (err) ->
			console.log err if err
				
	return @_domains

#
# Parse Groups/Notebooks
#
NotesSchema.methods.parse_groups = () ->
	self 		= @
	matches = @plain_txt.match regex.match.group

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
		map 			: map.toString()
		reduce 		: reduce.toString()
		query 		: query
		out 			: {inline: 1}

	mongoose.connection.db.executeDbCommand command, cb
		
	
mongoose.model('Note', NotesSchema)
