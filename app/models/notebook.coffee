Schema 			= mongoose.Schema
Base				= require 'sticky-model'
regex 			= require 'sticky-regex'
trebuchet 	= require('trebuchet')('d7fc51d8-e67a-49db-b232-80a5a2fcd84f')

without_at_sign = (v) ->
	return v.replace(/@/, '')

NotebookSchema = new Schema
	name  						: { type: String, required: true, trim: true, set: without_at_sign  }
	color							: { type: String, default: ''}
	created_at				: { type: Date, required: true }
	_owner 						: { type: Schema.ObjectId, ref: 'User' }


mongoose.model('Notebook', NotebookSchema)
