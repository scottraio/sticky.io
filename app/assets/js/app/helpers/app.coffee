window.match = 
	tag 			: /(^|\s)#([^\s]+)/g
	group 		: /(^|\s)@([^\s]+)/g
	notebook 	: /(^|\s)@([^\s]+)/g
	#tag 		: /(^|\s)#([_A-Za-z0-9]+)([\S\s]*?)/g
	#group 	: /(^|\s)@([_A-Za-z0-9]+)([\S\s]*?)/g
	link 		: /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g

window.save = (model, attrs, options) ->
	model.save {}, _.extend({data: JSON.stringify(attrs), contentType: 'application/json'}, options)

window.current_user = (attr) ->
	return App.current_user().attributes[attr]

window.load_templates = () ->
	try 
		ich.grabTemplates() 
	catch error
		null

window.is_touch_device = () ->
	if Zepto isnt undefined or Modernizr.touch is true
		return true
	else
		return false

# adds the methods min() and max() to arrays
# this was implented for the importer merge feature where 
# we needed to grab the minimum id in the array of desired merged fields
Array.prototype.max = () -> Math.max.apply(null, this)
Array.prototype.min = () -> Math.min.apply(null, this)

# best way to detect if a jQuery-selector returns an empty object
# http://stackoverflow.com/questions/920236/jquery-detect-if-selector-returns-null
$.fn.exists = () -> $(this).get(0) isnt undefined

window.os_name = () ->
	OSName="Unknown OS"
	OSName="Windows"  	if navigator.appVersion.indexOf("Win") 		isnt -1
	OSName="MacOS" 			if navigator.appVersion.indexOf("Mac") 		isnt -1
	OSName="UNIX" 			if navigator.appVersion.indexOf("X11")	 	isnt -1 
	OSName="Linux"			if navigator.appVersion.indexOf("Linux") 	isnt -1 

	return OSName

window.reset_events = (view) ->
	$(view.el).unbind()
	view.delegateEvents()

window.notebook_names = () ->
	names = []
	for notebook in notebooks
		names.push '@' + notebook.name
	return names

window.add_or_replace_query_var = (uri, key, value) ->
	re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i")
	separator = if uri.indexOf('?') isnt -1 then "&" else "?"
	if uri.match(re)
		return uri.replace(re, '$1' + key + "=" + value + '$2')
	else
		return uri + separator + key + "=" + value

window.remove_query_var = (uri, key) ->
	re = new RegExp("&?" + key + "=.*?(&|$)", "i")

	if uri.match(re)
		return uri.replace(re, '')
	else
		return uri

window.get_query_val = (key) ->
	match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search)
	return match && decodeURIComponent(match[1].replace(/\+/g, ' '))


window.format_date = (date) ->
	date = new Date(date)
	return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear()

window.show_profile = () ->
	$('#expanded-view').html ich.users_profile
		current_user: window.current_user
