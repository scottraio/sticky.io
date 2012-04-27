Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')
SHA2		= new (require('jshashes').SHA512)()
salt 		= 'sc2ishard'

encodePassword = (pass) ->
	return '' if typeof pass is 'string' and pass.length < 6 
	return SHA2.b64_hmac(pass, salt)

UserSchema = new Schema
				name  	 : { type: String, required: true, trim: true }
				email	 : { type: String, required: true, trim: true, unique: true, lowercase: true }
				password : { type: String, required: true, set: encodePassword }

UserSchema.path('name').validate 		Validations.uniqueFieldInsensitive('User', 'nick'), 'unique'
UserSchema.path('email').validate 		Validations.uniqueFieldInsensitive('User', 'email'), 'unique'
UserSchema.path('email').validate 		Validations.emailFormat, 'format'
UserSchema.path('password').validate 	Validations.cannotBeEmpty, 'password'

UserSchema.methods.validPassword = (pass) ->
	return true if encodePassword(pass) is this.password

mongoose.model('User', UserSchema)