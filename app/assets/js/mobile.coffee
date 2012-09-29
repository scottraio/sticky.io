#= require ./mobile/zepto.js
#= require ./vendor/icanhaz.js
#= require ./mobile/sidetap.js
#= require ./app/helpers/app.coffee

$(document).ready () ->


	#
	# Connect to Socket.IO
	socket.emit 'register', current_user

	socket.on 'notes:add', (data) ->
		console.log data
		#
		# Render the view
		$('ul.notes_board:first-child').before render_notes([data])


	st = sidetap()

	# 
	# Get notes
	render_notes = (notes) ->
		ich.notes_board
			notes								: notes
			note_message				: () -> this.message
			created_at_in_words	: () -> this.created_at #this.created_at && $.timeago(this.created_at)
			created_at_in_date 	: () -> this.created_at #self.format_date(this.created_at)
			has_subnotes				: () -> true if this._notes && this._notes.length > 0
			draggable						: () -> true unless this._notes && this._notes.length > 0
			subnote_count				: () -> this._notes.length if this._notes
			is_taskable					: () -> true if this.message && this.message.indexOf('#todo') > 0
			has_domains					: () -> true if this._domains && this._domains.length > 0
			domain							: () -> this.url.toLocation().hostname if this.url
			group_colors				: () -> "" #self.group_colors(this)

	#
	# Events
	new_note 		= $('#new-note')
	notes_list 	= $('#notes-list')

	$(".header-button.menu").on("click",st.toggle_nav)
	$('header .compose').click () -> st.show_section(new_note, {animation: 'upfrombottom'})
	$('#new-note a.cancel').click () -> st.show_section(notes_list, {animation: 'downfromtop'})
	$('#new-note a.save').click () -> save_note(); 

	#
	# Save new notes
	save_note = () ->
		ajax = $.ajax
			type: 'POST'
			url: "http://#{config.domain}/notes.json"
			data:
				message: $('#new-note textarea').val()
			complete: (data, status, xhr) ->
				st.show_section(notes_list, {animation: 'downfromtop'})
		return false

	#
	# Load notes on page load
	$.getJSON "/notes.json", (notes) ->
		#
		# Load notes into stage
		$('#stage').html render_notes(notes) 
	
		#
		# Bind event
		$('a.query').click (e) ->
			
			# reset pagination
			querystring = remove_query_var(document.location.search, 'page')
			window.current_page = 1
			# setup the querystring and navigate it
			param = $(e.currentTarget).attr('data-param')
			value = $(e.currentTarget).attr('data-param-val')

			if value
				$('#stage').html render_notes('/notes.json' + add_or_replace_query_var(querystring, param, value))
			else
				$('#stage').html render_notes('/notes.json' + remove_query_var(querystring, param))
			
			st.toggle_nav()
		