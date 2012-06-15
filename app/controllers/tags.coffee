helpers = require './helpers'
Note 	= app.models.Note
User 	= app.models.User
Tag 	= app.models.Tag

#
# GET /tags.json
#
exports.index = (req,res) ->
	helpers.render_json req, res, (done) ->
		Tag.update_index {_user:req.user._id}, () ->
			Tag.find {"value._user":req.user._id}, done
