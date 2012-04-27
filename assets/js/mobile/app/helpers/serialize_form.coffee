$.fn.serializeForm = () ->
	result = {}
	$(this).serializeArray().forEach (item, i) ->
		if item.name isnt undefined
			result[item.name] = item.value
			
  return result;