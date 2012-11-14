#= require ./app/index
#= require_tree ./app
#= require_tree ./jquery

class App.Main extends Backbone.View
	
	events:
		"click #delete-note .danger" 	: "delete_note"
		"click a.navigate" 						: "link_to_fragment"
		"click a.toggle-datepicker" 	: "link_to_calendar"
		"click a.query"								: "link_to_query"
		"click a.push" 								: "link_to_push"
		"submit .search form" 				: "search"
		
	initialize: ->
		#socket.on 'disconnect', () ->
		#	console.log 'disconnected'

		#
		# dropdown any dropdowns
		$('.dropdown-toggle').dropdown()

		#
		# set the current page for endless scrolling
		window.current_page = window.get_query_val('page') || 1

		#
		# Mixpanel Integration
		mixpanel.people.set
			'$email'			: current_user.email,
			'$name'				: current_user.name,
			'$last_login'	: current_user.last_sign_in_at
	
		#
		# animate the sidebar nav a bit
		setTimeout((->						
			$('ul.sidebar-nav').addClass('focus')
		), 300)
		
		#
		# date picker stuff
		$(document.body).click () ->
			$('.date-picker').hide()

		#
		# track the request
		#mixpanel.people.identify current_user._id

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

		# 
		# Socket.IO
		socket.on 'notes:add', (data) ->
			# Setup the view
			view 				= new App.Views.Notes.Index()	
			view.notes 	= [data]
			#
			# Render the view
			$('ul.notes_board:first-child').before view.ich_notes()
			# auto-link everything
			$('.message').autolink()
			# DnD
			window.dnd.draggable $('ul.notes_board:first-child li')
			window.dnd.droppable $('ul.notes_board:first-child li')

	delete_note: (e) ->
		note_id = $('#delete-note').attr('data-id')
		note = new App.Models.Note(id: note_id)
		note.destroy
			success: (model, res) ->
				# clear the html from the expanded view
				$("#expanded-view").html('')
				# remove the sticky from the inbox
				$("li.sticky[data-id=#{note_id}]").remove()
				$('#delete-note').modal('hide')
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
			