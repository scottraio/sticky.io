# AJAX Helper Functions
# these functions help simplify the complexity of a simple ajax call 
# with loading, remembering ($.address), and trapping stale sessions

window.navigate = (href) ->
	# if the page we are navigating to is the same page from where
	# we came from. Don't navigate to the href, just reload it
	if href is window.location.pathname
		push_url href
	else
		Backbone.history.navigate href.substr(1), true 

window.push_url = (href) ->
	Backbone.history.loadUrl href.substr(1)

window.render = (target, fn) ->
	if window.xhr isnt undefined
		load target, document.location.href, false, fn
	else
		fn()
	window.xhr = true;

# render_with_facebox
# if the facebox is loaded then render as usual, but use #facebox .content as our target
# if the facebox isnt loaded then launch a new one using the document.location as the href
#
# application_controller will know what actions are facebox only, and will halt the filter chain
# and return a splash page. From here, we expect backbone to render the action either using
# the existing facebox window, or will launch a new one. 
#
# Good to know: this procedure will fire 2 HTTP requests on full refresh. 
#  - #1 for the page load (splash) and will stop execution of further SQL calls
#  - #2 to fill the facebox with the ACTUAL content of the action.
window.render_with_facebox = (fn) ->
	if $("#facebox").is(":visible")
		render "#facebox .content", () ->
			$.facebox.center()
			fn()
	else
		remote_box document.location.href, fn
				

window.load = (target, href, apply_backbone, fn) ->
	t = setTimeout('loading(true)', 1000)
	$(target).load href, () ->
		reset_stage()
		loading(false)
		clearTimeout(t)
		load_templates()
		Backbone.history.loadUrl href.substr(1) if apply_backbone
		fn() if fn

# !!!! WARNING: window.remote_get is now depricated !!!!
# 
#
# remote_get is a function that encapsulates most of the ajax
# logic used for GET remote calls 
window.remote_get = (target, href, remember, fn) ->
	callback = () ->
		# trap_stale_sessions(xhr, target, data)
		loading(false)
		clearTimeout(t)
		load_templates()
		Backbone.history.loadUrl href.substr(1)
		fn() if fn
	
	# Fall back to normalcy for older browsers.
	if not window.history or not window.history.pushState
		window.location.href = href
		return true
	else
		t = setTimeout('loading(true)', 4000)
		close_all_pops_but_facebox()
		$.pjax({url:href, container:target, timeout:null, replace: !remember, success: (data) -> callback() })
		return false

# remote_post is a function that encapsulates most of the ajax
# logic used for POST remote calls
window.remote_post = (target, href, method) ->
	t = setTimeout('loading(true)', 4000)
	close_all_pops()
	ajax = $.ajax
		type: "POST"
		url: href
		data: {_method: method}
		dataType: "json"
		success: (data, status, xhr) ->
			redirect_to ajax # ajax event Location or back

window.redirect_to = (e) -> 
	location = e.getResponseHeader("Location")
	
	if location isnt undefined 
		if location is "back"
			history.go(-1)
		else
			navigate location

window.remote_box = (href, fn) ->
	$.get href, (data) ->
		$.facebox(data)
		$("#facebox .content").unbind()
		load_templates()
		push_url href
		fn() if fn

window.trap_stale_sessions = (xhr, target, data) ->
	if xhr.getResponseHeader('Session-Expired') != null
		window.location.reload(true)					
	else
		$(target).html(data)
		
window.loading = (show) ->
	$("#loading").html("Loading...")
	if show
		setTimeout("still_working()", 25000)
		$('#loading').show()
	else
		$("#loading").hide()

window.still_working = () ->
	setTimeout("somethings_wrong()", 500000)
	$("#loading").html("Still working...")

window.somethings_wrong = () -> $("#loading").html("Oh snap! Error!")

window.close_all_pops = () ->
	$.facebox.close()
	close_all_pops_but_facebox()
	
window.close_all_pops_but_facebox = () ->
	$(".popover").remove()
	$(".tipsy").remove()
	
	clear_flash()

window.reset_stage = () ->
	# reset the page's css -- sometimes pages are load as a facebox
	# and the stage needs to be reset back to white bg, etc
	$(".page").removeClass("blank")
	# this hack is here since endless scrolling is so important to reports
	# when a report is loaded we setup an interval called endless_scrolling_watcher
	# when we navigate or load a new page we then clear that setInterval
	# $(window).unbind("scroll") did not work
	if window.endless_scrolling_watcher
		window.clearInterval(window.endless_scrolling_watcher)
	
