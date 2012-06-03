http       = require('http');

host = "localhost"
port = 8000

http_get = (username, password, url, cb) ->
	options = {
		host: host,
		port: port,
		path: path,
		method: 'GET'
	}

	ret = false

	req = http.request options, (res) ->
		buffer = ''
		res.on 'data', (data) ->
			buffer += data

		res.on 'end', () ->
			cb(null,buffer)

	req.end()
	req.on 'error', (e) ->
		if (!ret)
			cb(e, null)


http_client = 
	get: (username, password, path, cb) -> http_get(username, password path, cb)

module.exports = http_client