Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'

without_at_sign = (v) ->
	return v.replace(/@/, '')

NotebookSchema = new Schema
	name  			: { type: String, required: true, trim: true, set: without_at_sign  }
	created_at	: { type: Date, required: true }
	_users 			: [{ type: Schema.ObjectId, ref: 'User' }]
	_owner 			: { type: Schema.ObjectId, ref: 'User' }
	
mongoose.model('Notebook', NotebookSchema)
