exports.render_json = (req,res,fn) ->
	switch req.params.format
		when 'json'
			fn( (err, items) ->
					res.writeHead 200, 'Content-Type': 'application/json'
					res.end JSON.stringify(items)
			)
		else res.render('index', {error: req.flash('error'), success: req.flash('success') })