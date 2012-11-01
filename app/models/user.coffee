wrench			= require 'wrench'
util 				= require 'util'
path				= require 'path'
trebuchet 	= require('trebuchet')('d7fc51d8-e67a-49db-b232-80a5a2fcd84f')

# Mongoose
Schema 			= mongoose.Schema
Base				= require 'sticky-model'
# message queue
stickymq 		= require 'sticky-kue'

# Security
SHA2				= new (require('jshashes').SHA512)()
salt 				= 'sc2ishard'

encodePassword = (pass) ->
	return '' if typeof pass is 'string' and pass.length < 6 
	return SHA2.b64_hmac(pass, salt)

#
# Mongoose Schema
UserSchema = new Schema
	name  	 				: { type: String, required: true, trim: true }
	email	 					: { type: String, required: true, trim: true, unique: true, lowercase: true }
	phone_number	 	: { type: String, trim: true, default: null }
	password 				: { type: String, required: true, set: encodePassword }
	googleId 				: { type: String }
	last_sign_in_at : { type: Date, default: null }
	theme 					: { type: String, default: 'bright' }

UserSchema.path('email').validate 		Base.uniqueFieldInsensitive('User', 'email'), 'unique'
UserSchema.path('email').validate 		Base.emailFormat, 'format'
UserSchema.path('password').validate 	Base.cannotBeEmpty, 'password'


UserSchema.methods.broadcast = (route, data) ->
	io.sockets.in(@_id).emit route, data

UserSchema.methods.validPassword = (pass) ->
	return true if encodePassword(pass) is @password

UserSchema.methods.registerXMPPBot = () ->
	stickymq.registerXMPPBot(@email)

UserSchema.methods.sendWelcomeEmail = () ->
	self = @
	trebuchet.fling
		params:
			from: 'notify@sticky.io'
			to: self.email
			subject: 'Welcome to Sticky!'
		html: 'app/emails/welcome.html'
		text: 'app/emails/welcome.txt'
		data:
			foo: 'Bar'
	, (err, response) ->
		# win

UserSchema.methods.setupDefaultNotebooks = () ->
		self = @
		home = new app.models.Notebook()
		home.set '_owner', self
		home.set 'created_at', new Date()
		home.set 'name', 'home'
		home.set 'color', 'blue'
		home.save (err,notebook) ->
			console.log(err) if err
			work = new app.models.Notebook()
			work.set '_owner', self
			work.set 'created_at', new Date()
			work.set 'name', 'work'
			work.set 'color', 'red'
			work.save (err,notebook) ->
				console.log(err) if err
				school = new app.models.Notebook()
				school.set '_owner', self
				school.set 'created_at', new Date()
				school.set 'name', 'school'
				school.set 'color', 'green'
				school.save (err,notebook) ->
					console.log(err) if err

			

mongoose.model('User', UserSchema)
