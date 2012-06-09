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

# there are many cases where we want to disabled a link, button, etc
# after we clicked it. submiting a form is a great one.
window.disable_button = (obj) ->
	$(obj).attr("disabled", true)
	$(obj).css("background-color", "#ccc")

window.get_gravatar = (email, size) ->
	# MD5 (Message-Digest Algorithm) by WebToolkit
	# http://www.webtoolkit.info/javascript-md5.html
	size = size || 80
	'http://www.gravatar.com/avatar/' + MD5(email) + '.jpg?s=' + size + "&d=mm"

window.os_name = () ->
	OSName="Unknown OS"
	OSName="Windows"  	if navigator.appVersion.indexOf("Win") 		isnt -1
	OSName="MacOS" 		if navigator.appVersion.indexOf("Mac") 		isnt -1
	OSName="UNIX" 		if navigator.appVersion.indexOf("X11")	 	isnt -1 
	OSName="Linux"		if navigator.appVersion.indexOf("Linux") 	isnt -1 

	return OSName

window.reset_events = (view) ->
	$(view.el).unbind("click")
	$(view.el).unbind("dblclick")
	$(view.el).unbind("tap")
	$(view.el).unbind("submit")
	$(document).unbind("keydown")
	view.delegateEvents()

