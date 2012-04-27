window.click_or_tap = (events) ->
	# for property in obj, add "click " to property and use original value
	new_obj = {} 
	for property, value of events
		if Zepto is undefined
			new_obj["click " + property] = events[property]
		else
			new_obj["tap " + property] = events[property]
	return new_obj


class App.Main extends Backbone.View
	
	events: click_or_tap {
		"div"						: "clear_state"
		"a.remote" 					: "link_to_remote"
		"a.navigate" 				: "link_to_fragment"
		"a.remote-delete" 			: "link_to_delete"
		"a#submit"					: "link_to_submit"
		"a[rel*=facebox]"			: "link_to_facebox"
		".empty_results"			: "add_new_item"
		".alert-message .close" 	: "close_flash"
		"ul.tabs li"				: "link_to_tab"
		"#load-settings" 			: "load_settings"
		"#load-add-menu" 			: "load_add_menu"	
	}
		
	initialize: ->
		if is_touch_device()
			# only do this if not on a touch device
			$(document).delegate 'body', 'click', (e) ->
				$(e.target).trigger('tap')
				return false
		else 
			$("#content").resizable
				minWidth:$(".page").width()
				maxWidth:$(window).width() - 10
				handles:'w'

			
	link_to_fragment: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false
	
	link_to_remote: (e) ->
		# an easy ajax function that gives links the ability to become a "remote link"
		_this 		= $(e.currentTarget)
		target 		= _this.attr("rel")
		href		= _this.attr("href")
		if target
			return remote_get(target, href, _this.hasClass("remember"))
		else
			$.get(href)
			return false
			
	link_to_delete: (e) ->
		# easy ajax function to perform a delete action
		_this 	= $(e.currentTarget);
		smoke.confirm 'You are about to destroy this. Are you sure?', (e) ->
			if (e)
				remote_post(_this.attr("rel"), _this.attr("href"), 'delete')
		return false
		
	link_to_submit: (e) ->
		# example: 
		# <form action="some/create|update/action">
		# 	<%= link_to 'Submit', "#", :rel => "#stage" :class => "keep_facebox_open" %>
		# </form>
		# tag a link or button with the id="submit" and rel="#some_target"
		# to have that objects parent form be submitted in ajax. oh yea, it will
		# also disable the button or link to prevent double submissions
		_this 	= $(e.currentTarget)
		disable_button(_this);
		form 	= _this.closest("form")
		target  = _this.attr("rel")

		ajax = $.ajax
			type: "POST"
			headers:
				"Workory-Client": @desktop
			url: $(form).attr("action")
			data: $(form).serialize()
			dataType: "json"
			complete: (data, status, xhr) ->
				location = ajax.getResponseHeader("Location")
				if location is undefined or location is null
					console.log "'Location' was not found in the response headers"
				else
					if target is undefined or target is "#stage" or target is "#facebox .content"
						navigate location
					else
						$(target).load(location)
				
				close_all_pops() unless _this.hasClass("keep_facebox_open")
				$("#needs_save").val("")
				
		return false

	link_to_facebox: (e) ->
		close_all_pops_but_facebox()
		href = $(e.currentTarget).attr("href")
		remote_box(href)

		return false
		
	link_to_tab: (e) ->
		$(e.currentTarget).parent("ul").children("li").removeClass("active")
		$(e.currentTarget).addClass("active")
		
		navigate $("a", e.currentTarget).first().attr("href")

		return false
		
	add_new_item: (e) ->
		link = $(".empty_results .add_new_item a")
		if Zepto is undefined
			link.trigger("click")
		else
			link.trigger("tap")
			
		return false

	clear_state: (e) ->
		$(".sidebar-footer-add-menu").remove() unless $(e.target).parents(".sidebar-footer-add-menu").length isnt 0
		$("#editable-modal").remove() unless $(e.target).parents("#editable-modal").length isnt 0
		

	close_flash: (e) ->
		$(e.currentTarget).parents(".alert-message").remove()

	load_settings: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false

	load_add_menu: (e) ->
		$(".sidebar-footer").after ich.sidebarFooterAddMenu()
		return false