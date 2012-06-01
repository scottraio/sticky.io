exports.to_system_format = (v) ->
	#
	# convert the name of the company to a 'system name'
	# excludes all !#$%^&*(){}[], only allow underscores and dashes
	#
	return v.replace(' ', '_').replace(/[^-\sa-zA-Z0-9$]/g, '')