# copy from lib/regex.coffee
window.match = 
	tag 		: /(^|\s)#([^\s]+)/g
	group 	: /(^|\s)@([^\s]+)/g
	link 		: /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g

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
	
	events:
		"click a.remote" 							: "link_to_remote"
		"click a.navigate" 						: "link_to_fragment"
		"click a.order"								: "link_to_sort"
		"click .sidebar li" 					: "link_to_notebook"
		"click a.push" 								: "link_to_push"
		"click a.remote-delete" 			: "link_to_delete"
		
	initialize: ->
		$('.dropdown-toggle').dropdown()
		
		today					= new Date()
		threedaysago 	= new Date(new Date().setDate(today.getDate() - 3))

		# date picker
		$('.date-picker').DatePicker
			format: '/m/d/Y',
			flat: true,
			extraHeight: 0,
			mode: 'range',
			date: [threedaysago, today],
			current: new Date(),
			calendars: 1,
			starts: 1
			onChange: (formated, dates) ->
				d1 		= new Date(dates[1])
				d2		= new Date(dates[0])
				start = d1.toJSON()
				end 	= d2.toJSON()
				navigate "/notes?start=#{start}&end=#{end}"

		new App.Views.Notes.New(el: $('#new-sticky-header'))

	link_to_sort: (e) ->
		direction = $(e.currentTarget).attr('data-direction')
		search = document.location.search.replace(/(&|order=)[^\&]+/, '')
		search = search + "&order=#{direction}"
		navigate document.location.pathname + search
		return false

	#
	#
	#
	# 	Legacy Methods
	#
	#
	#---------------------------------------------------------


	link_to_fragment: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false

	link_to_notebook: (e) ->
		navigate $(e.currentTarget).children("a").attr("href")
		return false

	link_to_push: (e) ->
		push_url $(e.currentTarget).attr("href")
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
