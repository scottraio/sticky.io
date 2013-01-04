#= require ./app/index
#= require_tree ./app
#= require_tree ./jquery
#= require ./app/sockets

class App.Main extends Backbone.View
	
	keyboardEvents:
		'command+alt+o'	: 'new_note'

	events:
		"click #delete-note .danger" 	: "delete_note"
		"click a.navigate" 						: "link_to_fragment"
		"click a.needs-help" 					: "needs_help"
		"click a.toggle-datepicker" 	: "link_to_calendar"
		"click a.query"								: "link_to_query"
		"click a.view-as-list"				: "view_as_list"
		"click a.view-as-grid"				: "view_as_grid"
		"click a.push" 								: "link_to_push"
		"submit .search form" 				: "search"
		
	initialize: ->
		# 
		# Brief aside on super: JavaScript does not provide a simple way to call super — 
		# the function of the same name defined higher on the prototype chain.
		Backbone.View.prototype.initialize.apply(@, arguments);

		#
		# dropdown any dropdowns
		$('.dropdown-toggle').dropdown()

		#
		# set the current page for endless scrolling
		window.current_page = window.get_query_val('page') || 1
	
		#
		# animate the sidebar nav a bit
		setTimeout((->						
			$('ul.sidebar-nav').addClass('focus')
		), 300)

		#
		# listen for sockets
		sockets = new App.Sockets()
		sockets.listen()

		#
		#
		# date picker stuff
		$(document.body).click () ->
			$('.date-picker').hide()

		#
		# setup date controls
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
				d1 		= new Date(dates[0])
				d2		= new Date(dates[1])
				start = d1.toJSON()
				end 	= d2.toJSON()
				navigate "/notes?start=#{start}&end=#{end}"

	delete_note: (e) ->
		note_id = $('#delete-note').attr('data-id')
		note = new App.Models.Note(id: note_id)
		note.destroy
			success: (model, res) ->
				# clear the html from the expanded view
				$("#expanded-view .expanded-view-anchor").html('')
				# remove the sticky from the inbox
				$("li.sticky[data-id=#{note_id}]").remove()
				$('#delete-note').modal('hide')
				$('#expanded-view').hide()
		return false

	new_note: (e) ->
		push_url '/notes/new'
		console.log('test')
		return false

	search: (e) ->
		e.preventDefault()
		keyword = $('#keyword').val()
		navigate '/notes' + add_or_replace_query_var(document.location.search, 'keyword', keyword)
		return false

	link_to_calendar: (e) ->
		e.stopPropagation()
		$('.date-picker').toggle()
		return false

	needs_help: (e) ->
		$('#help').toggleClass('hide');
		$('body').toggleClass('needs-help');
		$("#habla_window_div").toggleClass('visible');
		return false

	link_to_query: (e) ->
		# reset pagination
		querystring = remove_query_var(document.location.search, 'page')
		window.current_page = 1
		# setup the querystring and navigate it
		param = $(e.currentTarget).attr('data-param')
		value = $(e.currentTarget).attr('data-param-val')
		if value
			navigate '/notes' + add_or_replace_query_var(querystring, param, value)
		else
			navigate '/notes' + remove_query_var(querystring, param)
		return false
	
	link_to_fragment: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false

	link_to_push: (e) ->
		push_url $(e.currentTarget).attr("href")
		return false

	view_as_grid: (e) ->
		$("#inbox").addClass("grid")
			
	view_as_list: (e) ->
		$("#inbox").removeClass("grid")