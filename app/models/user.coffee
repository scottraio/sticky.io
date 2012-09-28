wrench			= require 'wrench'
util 				= require 'util'
path				= require 'path'
trebuchet 	= require('trebuchet')('d7fc51d8-e67a-49db-b232-80a5a2fcd84f')

Schema 			= mongoose.Schema
Base				= require 'sticky-model'

SHA2				= new (require('jshashes').SHA512)()
salt 				= 'sc2ishard'
xmpp 				= require 'simple-xmpp'


encodePassword = (pass) ->
	return '' if typeof pass is 'string' and pass.length < 6 
	return SHA2.b64_hmac(pass, salt)

UserSchema = new Schema
	name  	 				: { type: String, required: true, trim: true }
	email	 					: { type: String, required: true, trim: true, unique: true, lowercase: true }
	phone_number	 	: { type: String, trim: true, default: null }
	password 				: { type: String, required: true, set: encodePassword }
	googleId 				: { type: String }
	last_sign_in_at : { type: Date, default: null }

UserSchema.path('email').validate 		Base.uniqueFieldInsensitive('User', 'email'), 'unique'
UserSchema.path('email').validate 		Base.emailFormat, 'format'
UserSchema.path('password').validate 	Base.cannotBeEmpty, 'password'

UserSchema.methods.validPassword = (pass) ->
	return true if encodePassword(pass) is @password

UserSchema.methods.registerXMPPBot = () ->
	register = new xmpp.Element('presence', {type: 'subscribe', to: this.email})
	xmpp.conn.send(register)

UserSchema.methods.sendWelcomeEmail = () ->
	self = @
	trebuchet.fling
		params:
			from: 'notes@sticky.io'
			to: self.email
			subject: 'Welcome to Sticky!'
		html: 'app/emails/welcome.html'
		text: 'app/emails/welcome.txt'
		data:
			foo: 'Bar'
	, (err, response) ->
		# win


mongoose.model('User', UserSchema)
