#
#
# Setters
exports.to_system_format = (v) ->
	#
	# convert the name of the company to a 'system name'
	# excludes all !#$%^&*(){}[], only allow underscores and dashes
	#
	return v.replace(' ', '_').replace(/[^-\sa-zA-Z0-9$]/g, '')

#
#
# Validations
exports.uniqueFieldInsensitive =  ( modelName, field ) ->
	return (val, cb) ->
		if val && val.length
			if this.isNew
				mongoose.models[modelName].where(field, new RegExp('^'+val+'$', 'i')).count((err,n) -> cb( n < 1 ) )
			else
				cb(true)
		else
			cb( false )

exports.titleFormat = (val) ->
	return (/^[a-zA-Z0-9_.]+$/i).test(val) 

exports.emailFormat = (val) ->
	return (/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i).test(val)

exports.cannotBeEmpty = (val) ->
	if typeof val is 'string' 
		if val.length
			return true
		else
			return false
	else
		return false

exports.validJSON = (val) ->
	if typeof val is 'string' 
		try 
			JSON.parse(val)
		catch e
			return false

		return true
	else
		return false
