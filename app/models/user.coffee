wrench			= require 'wrench'
util 				= require 'util'
path				= require 'path'

Schema 			= mongoose.Schema
Base				= require 'sticky-model'

SHA2				= new (require('jshashes').SHA512)()
salt 				= 'sc2ishard'
xmpp 				= require 'simple-xmpp'


encodePassword = (pass) ->
	return '' if typeof pass is 'string' and pass.length < 6 
	return SHA2.b64_hmac(pass, salt)

UserSchema = new Schema
	name  	 	: { type: String, required: true, trim: true }
	email	 		: { type: String, required: true, trim: true, unique: true, lowercase: true }
	password 	: { type: String, required: true, set: encodePassword }
	googleId 	: { type: String }

UserSchema.path('email').validate 		Base.uniqueFieldInsensitive('User', 'email'), 'unique'
UserSchema.path('email').validate 		Base.emailFormat, 'format'
UserSchema.path('password').validate 	Base.cannotBeEmpty, 'password'

UserSchema.methods.validPassword = (pass) ->
	return true if encodePassword(pass) is @password

UserSchema.methods.registerXMPPBot = () ->
	register = new xmpp.Element('presence', {type: 'subscribe', to: this.email})
	xmpp.conn.send(register)


mongoose.model('User', UserSchema)
