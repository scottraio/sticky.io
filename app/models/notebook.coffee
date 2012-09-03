Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'
trebuchet 	= require('trebuchet')('d7fc51d8-e67a-49db-b232-80a5a2fcd84f')

without_at_sign = (v) ->
	return v.replace(/@/, '')

NotebookMemberSchema = new Schema
	_user 			: { type: Schema.ObjectId, ref: 'User' }
	sent_at 		: { type: Date, default: null }
	accepted_at : { type: Date, default: null }

NotebookSchema = new Schema
	name  						: { type: String, required: true, trim: true, set: without_at_sign  }
	created_at				: { type: Date, required: true }
	_members 					: [NotebookMemberSchema]
	_owner 						: { type: Schema.ObjectId, ref: 'User' }

NotebookSchema.methods.find_new_members = (emails, cb) ->
	app.models.User
		.where('email').in(emails)
		.where('email').nin(this._members).run (err, users) ->
			members = []
			for user in users
				members.push {_user: user, sent_at: null}
			cb(members)


NotebookSchema.methods.invite_new_members = (emails, cb) ->
	self = @
	
	@find_new_members emails, (members) ->
		for member in members
			if member.sent_at is null	or member.accepted_at is null
				console.log 'send email'
		cb(members)


NotebookSchema.methods.invite_user = (user) ->
	trebuchet.fling
		params:
			from: 'notes@sticky.io',
			to: user.email,
			subject: "#{self._owner.name} has invited you to join the notebook @#{self.name}"
		html: 'path/to/template/fling.html',
		text: 'path/to/template/fling.txt',
		data:
			foo: 'Bar'
	, (err, resp) ->
		# win

mongoose.model('Notebook', NotebookSchema)
