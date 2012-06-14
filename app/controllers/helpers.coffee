exports.render_json = (req,res,fn) ->
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
		else exports.render_page('index', req, res)

exports.render_page = (page,req,res) ->
	console.log app
	app.models.Tag.find {}, (err, tags) ->

		res.render(page, {
			error: 			req.flash('error')
			success: 		req.flash('success')
			current_user: 	JSON.stringify(req.user)
			is_logged_in: 	true if req.user
			tags:			tags
		})
		