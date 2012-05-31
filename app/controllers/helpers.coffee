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
		else res.render('index', {error: req.flash('error'), success: req.flash('success') })