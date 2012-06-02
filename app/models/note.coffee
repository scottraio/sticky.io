
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


NotesSchema.pre 'save', (next) ->
	next()

NotesSchema.methods.parse_tags = () ->
	self = @
	tag_regex = /[#]+[A-Za-z0-9-_]+/g

	while ((tags = tag_regex.exec(this.message)) != null)
		self.tags.push tags[0]

NotesSchema.methods.parse_links = () ->
	self = @
	link_regex = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g

	while ((links = link_regex.exec(this.message)) != null)
		self.links.push links[0]


mongoose.model('Note', NotesSchema)