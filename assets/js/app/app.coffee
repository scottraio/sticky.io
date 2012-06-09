window.App =
	Models: {}
	Collections: {}
	Controllers: {}
	Routers: {}
	Views: {}

# copy from lib/regex.coffee
window.match = 
	tag 	: /(^|\s)#([^\s]+)/g
	link 	: /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g

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
		"a.post_message"			: "post_message"
		'.tag'						: 'search'
		"a.remote" 					: "link_to_remote"
		"a.navigate" 				: "link_to_fragment"
		"a.remote-delete" 			: "link_to_delete"
		"button[type=submit]"		: "link_to_submit"
		"ul.tabs li"				: "link_to_tab"
		"#load-settings" 			: "load_settings"
	}
		
	initialize: ->
		$('.dropdown-toggle').dropdown()
		

	post_message: (e) ->
		push_url '/notes/new'
		return false

	search: (e) ->
		self = @
		tag = $(e.currentTarget).attr('data-tag-name').replace(" #", "")

		$.post '/notes/filter.json', {tags: [tag]}, (items) ->
			notes = new App.Views.Notes.Index(el: $("#main"), tags: [tag])
			notes.render_list(items)
			# clear twitter bootstrap dropdowns
			$('html').trigger('click.dropdown.data-api')

		return false

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
		remote_post(_this.attr("rel"), _this.attr("href"), 'delete')
		return false
		
	link_to_submit: (e) ->
		form 	= $(e.currentTarget).closest("form")
		form.submit()
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