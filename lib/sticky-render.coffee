Tag 			= app.models.Tag
Notebook 	= app.models.Notebook

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
			ua = req.headers['user-agent']

			if /mobile/i.test(ua) or /like Mac OS X/.test(ua) or /iPhone/.test(ua) or /iPad/.test(ua) or /Android/.test(ua)
				mobile = true

			if mobile
				exports.render_page('mobile', req, res)
			else
				exports.render_page('index', req, res)

exports.render_page = (page,req,res) ->
	res.setHeader "Cache-Control", "public, max-age=#{5 * 60}"
	
	exports.update_index req, () ->
		Tag.where('value._user', req.user.id).run (err, tags) ->
			Notebook.where('_owner', req.user.id).run (err, notebooks) ->

					res.render(page, {
						error         : 	req.flash('error')
						success       :   req.flash('success')
						current_user  : 	JSON.stringify(req.user)
						is_logged_in  : 	true if req.user
						tags          :		tags
						notebooks     : 	notebooks
						req           :		req
						config 				: 	settings
					})
		

exports.update_index = (req,cb) ->
	Tag.update_index {_user:req.user.id}, () ->
		cb()


