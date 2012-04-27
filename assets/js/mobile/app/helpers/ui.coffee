# https://github.com/documentcloud/backbone/pull/307
# Use JSONP instead of JSON
window.JSONPSync = (method, model, options) ->
	options.timeout = 10000
	options.dataType = "jsonp"
	Backbone.sync(method, model, options)
	
window.base_path = () -> "https://app.workory.com"

window.url_for = (path) -> "#{path}"

window.bind_pressed_event = () ->
	#$("ul[data-role=listview] li").bind "tap", () ->
	#	$(this).addClass("pressed")
		
	#$("ul[data-role=listview] li").bind "touchend", () ->
	#	$(this).removeClass("pressed")

window.page = (size) ->
	if size is "full"
		#$("#header").addClass("hide")
		#$("#header").bind 'webkitTransitionEnd', (event) -> 
		#	$("#header").hide()
		
		#$("#tabbar").addClass("hide")
		#$("#tabbar").bind 'webkitTransitionEnd', (event) -> 
		#	$("#tabbar").hide()
			
		#setHeight()
	else
		#$("#header").show()
		#$("#header").removeClass("hide")
		#$("#header").unbind 'webkitTransitionEnd'
		
		#$("#tabbar").show()
		#$("#tabbar").removeClass("hide")			
		#$("#tabbar").unbind 'webkitTransitionEnd'
		#setHeight()

window.mobui = {}

mobui.set_title = (title) ->
	$("header h1").html(title)
	
mobui.set_navbar = (item) ->
	$("a[data-tabbar-item]").removeClass("enabled")
	$("a[data-tabbar-item=#{item}]").addClass("enabled")
	
mobui.clear_left_buttons = () ->
	$("header li.left").html("")
	
mobui.clear = () ->
	$("header li.right").html("")
	$("header li.left").html("")

mobui.back_button = (title) ->
	$("header li.left").html ich.backbutton(title: title)
	$("header li.left a.back div.body").width($("div#header li.left a.back div.body p").width() + 16)
	
mobui.add_button = (url) ->
	$("header li.right").html ich.regbutton(title: "+", url: url, class: "add")

mobui.init_pages = (length) ->
	$width = $("#wrapper").width()
	$("#slider").css("width", (length * $width))
	$(".page").css("width", $width)


window.current_user = (user) ->
	if user
		@user = app.models.user
	else
		return @user
		
		