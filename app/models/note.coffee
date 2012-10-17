$						= require 'jquery'
_						= require 'underscore'

Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'


NotesSchema = new Schema
	message  		: { type: String, required: true, trim: true }
	plain_txt  	: { type: String, required: true, trim: true, default: ' ' }
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
NotesSchema.index { _parent: 1, groups: 1, deleted_at: 1, _user: 1 }
NotesSchema.index { tags: 1, deleted_at: 1, _user: 1 }
NotesSchema.index { _parent: 1, deleted_at: 1, _user: 1 }
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
			app.models.User.findOne {_id: user._id}, (err, user) ->
				user.broadcast('notes:add', note)

			cb(null, note)
		else
			cb(err)

#
# Stacking

NotesSchema.statics.stack = (user, options, cb) ->
	@note_and_parent user, {child_id: options.child_id, parent_id: options.parent_id}, (child, parent) ->
		# assign child id to parent
		parent._notes.push child._id
		# assign parent to child
		child._parent 		= parent._id
		child.stacked_at 	= new Date()
		child.save (err) -> 
			parent.save (err) ->
				cb(child, parent)
		

NotesSchema.statics.restack = (user, options, cb) ->
	@from_note_to_note user, {child_id: options.child_id, old_id: options.old_id, parent_id: options.parent_id}, (child, old_parent, parent) ->
		# magic
		old_parent._notes.remove(child._id)
		parent._notes.push(child._id)
		child._parent = parent._id

		child.save (err) -> 
			parent.save (err) ->
				old_parent.save (err) ->
					cb(child, old_parent, parent)
 
NotesSchema.statics.unstack = (user, options, cb) ->
	@note_and_parent user, {child_id: options.child_id, parent_id: options.parent_id}, (child, parent) ->
		# magic
		parent._notes.remove(child._id)
		child._parent = null

		child.save (err) -> 
			parent.save (err) ->
				cb(child, parent)
			

#
# Parses all tags, links, and groups from message 
NotesSchema.methods.parse = () ->
	# sets up a the 'plain_txt' field in the DB
	# we use this plain_txt for a variety of use cases e.g. parsing notes (parse straight text, dont muddle with html)
	@simplify() 
	tags 			= @parse_tags()
	links 		= @parse_links()
	notebooks = @parse_groups()


NotesSchema.methods.simplify = () ->
	if /<(?:.|\n)*?>/gm.test(@message)
		@set 'plain_txt', $("<div>#{@message}</div>").text() # strip any html, and just store the plain text message
	else
		@set 'plain_txt', @message

#
# Parse tags i.e. #todo, #urgent, #cool-links
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
NotesSchema.methods.parse_groups = () ->
	self 			= @
	matches 	= @plain_txt.match regex.match.group
	notebooks = []

	if matches

		for group in matches
			# strip tags down and add them to the array
			# e.g. #todo turns into todo
			notebooks.push group.replace(/@/, '').replace(/\s/, '').toLowerCase()

	return @groups = notebooks

#
# Map/Reduce
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
		
#
# Stacking helper methods
NotesSchema.statics.last_note = (user, cb) ->
	app.models.Note.where('_user',user._id)
		.where('_parent', null)
		.limit(1)
		.sort('created_at', -1)
		.run (err, last_note) ->
			cb(last_note[0])

NotesSchema.statics.note_and_parent = (user, options, cb) ->
	app.models.Note.findOne {_id:options.child_id, _user:user}, (err, child) ->			
		app.models.Note.findOne {_id:options.parent_id, _user:user}, (err, parent) ->
			cb(child,parent)

NotesSchema.statics.from_note_to_note = (user, options, cb) ->
	app.models.Note.findOne {_id:options.child_id, _user:user}, (err, child) ->
		app.models.Note.findOne {_id:options.old_id, _user:user}, (err, old_parent) ->		
			app.models.Note.findOne {_id:options.parent_id, _user:user}, (err, parent) ->
				cb(child,old_parent,parent)

#
# Mongoose version of a lazy join
# populate stacks with subnote data
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

#
# Set the model!
mongoose.model('Note', NotesSchema)