Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
Validations = require('./validations.coffee')


HelpSchema = new Schema
					title  	 : { type: String, required: true, trim: true }
					body	 : { type: String, required: true, trim: true,  }


HelpSchema.path('title').validate Validations.cannotBeEmpty, 'title'
HelpSchema.path('body').validate Validations.cannotBeEmpty, 'body'


mongoose.model('Help', HelpSchema)