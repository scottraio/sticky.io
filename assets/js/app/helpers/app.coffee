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

# handle beta features
window.beta = () ->
	$.facebox({ div: '#beta' }, "modal")
	$(".close").hide()
	
# log messages to the console only if we are in debug mode
window.logger = (message, debug) -> console.log(message) if debug == true or debug == "true"

# used for plotting points on google maps
window.plot = (id, lat, lng, zoom) ->
	myLatlng = new google.maps.LatLng(lat, lng);
	
	map = new google.maps.Map document.getElementById(id), 
		zoom: zoom || 13,
		scrollwheel: true,
		center: myLatlng,
		disableDefaultUI: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP

	marker = new google.maps.Marker
		position: myLatlng, 
		map: map, 
		title:""

window.auto_focus = (el) ->
	$("input[type=text]:first", el).focus()

window.facebox_auto_focus = (el) ->
	setTimeout (() -> auto_focus(el)), 0

window.settings_auto_adjust = (el) ->
	$(".side_list_nav").height($(".settings-content").height())

window.am_i_following = (button) ->
	if button.attr("data-following") is "true"
		button.addClass("active")
		button.html("<span class='icon16 i16_white_checkmark'></span> Following")

window.toggle_following = (button) ->
	if button.hasClass("active")
		button.removeClass("active")
		button.html("<span class='icon16 i16_add'></span> Follow")
	else
		button.addClass("active")
		button.html("<span class='icon16 i16_white_checkmark'></span> Following")

window.load_script = (url) ->
	e 		= document.createElement('script')
	e.async = true
	e.src 	= document.location.protocol + '//' + url
	x 		= document.getElementsByTagName('script')[0]
	x.parentNode.insertBefore(e, x)

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

window.flash = (message, type) ->
	if message isnt null		
		$("body").append ich.flash(message: message, type: type)
		setTimeout("$('.alert-message').css('top', 0)", 0)
		setTimeout("clear_flash()", 5000)

	return false

window.clear_flash = () ->
	$(".alert-message").css("top", -40)
	#$(".alert-message").remove()

window.reset_events = (view) ->
	$(view.el).unbind("click")
	$(view.el).unbind("dblclick")
	$(view.el).unbind("tap")
	$(document).unbind("keydown")
	view.delegateEvents()

