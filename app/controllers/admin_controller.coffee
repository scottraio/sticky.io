_ 			= require 'underscore'
render 	= require 'sticky-render'

# 
# admin homepage
# GET /admin
exports.root = (req, res) ->
	if req.user.is_admin or req.user.email is 'scottraio@gmail.com'

		app.models.User.where().sort('last_sign_in_at', -1).run (err, users) ->
			res.render 'admin',
				current_user  : req.user
				users 				: users
	else
		res.redirect('/notes')


#
# grants admin priv
# GET /admin/grant/:id
exports.grant = (req, res) ->
	if req.user.is_admin or req.user.email is 'scottraio@gmail.com'

		app.models.User.findOne {_id:req.params.id}, (err, user) ->

			user.set 'is_admin', true

			user.save (err) -> 
				if err
					console.log(err)

				res.redirect('/admin')
	else
		res.redirect('/notes')

#
# revokes an user
# GET /admin/grant/:id
exports.revoke = (req, res) ->
	if req.user.is_admin or req.user.email is 'scottraio@gmail.com'

		app.models.User.findOne {_id:req.params.id}, (err, user) ->

			user.set 'is_admin', false

			user.save (err) -> 
				if err
					console.log(err)

				res.redirect('/admin')
	else
		res.redirect('/notes')