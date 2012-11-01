_ = require 'underscore'

exports.json = (req,res,fn) ->
	switch req.params.format
		when 'json'			
			cb = (err, items) ->
				if err
					res.writeHead 500, 'Content-Type': 'application/json'
					res.write JSON.stringify({error:err})
					res.end('')
				else
					res.writeHead 200, 'Content-Type': 'application/json'
					res.write JSON.stringify(items||[])
					res.end('\n')
			fn(cb)
		else
			if @is_mobile(req)
				exports.render_page('mobile/index', req, res)
			else
				exports.render_page('index', req, res)

exports.render_page = (page,req,res) ->
	#res.setHeader "Cache-Control", "public, max-age=#{5 * 60}"
	
	app.models.Tag.update_index {_user:req.user.id}, (tags) ->
		app.models.Notebook.where('_owner', req.user.id).run (err, notebooks) ->

				res.render(page, {
					error         : 	req.flash('error')
					success       :   req.flash('success')
					current_user  : 	_.pick(req.user, 'name', 'email', '_id', 'theme', 'phone_number')
					is_logged_in  : 	true if req.user
					tags          :		tags
					notebooks     : 	notebooks
					req           :		req
					config 				: 	settings
				})

exports.is_mobile = (req) ->
	ua = req.headers['user-agent']
	return true if /mobile/i.test(ua) or /like Mac OS X/.test(ua) or /iPhone/.test(ua) or /iPad/.test(ua) or /Android/.test(ua)