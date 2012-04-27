# memory (localStorage) functions
#

# function for retrieving the options for the grid state
window.memory = (superkey) ->
	if localStorage isnt undefined
		json = JSON.parse(localStorage.getItem(superkey))
		json = {} if json is null
		return json
	else
		# no native support for HTML5 storage :(
		# maybe try dojox.storage or a third-party solution
		return {}
		
# function to set the local storage so we can call on it later to build perfect URL options
window.set_memory = (superkey,key,value,fn) ->
	mem = memory(superkey)
	if key isnt null
		# extend the object to 
		mem[key] = value
		fn(mem) if (fn isnt undefined)
		# set the memory
		localStorage.setItem(superkey, JSON.stringify(mem))
		return memory(superkey)
