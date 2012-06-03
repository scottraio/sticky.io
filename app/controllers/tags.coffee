helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User

#
# GET /tags.json
#
exports.index = (req,res) ->
	helpers.render_json req, res, (done) ->
		done(null, [])

        
