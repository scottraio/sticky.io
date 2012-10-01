#= require ./mobile/zepto.js
#= require ./mobile/zepto.fasttap.js
#= require ./vendor/icanhaz.js
#= require ./mobile/sidetap.js
#= require ./app/helpers/app.coffee
#= require ./app/helpers/mixins.coffee

$(document).ready () ->

	new_note 		= $('#new-note')
	notes_list 	= $('#notes-list')

	#
	# Connect to Socket.IO
	socket.on 'notes:add', (data) ->
		console.log data
		#
		# Render the view
		$('ul.notes_board:first-child').before render_notes([data])


	#
	# Start Sidetap
	st = sidetap()

	# 
	# Get notes
	render_notes = (notes) ->
		ich.notes_board
			notes								: notes
			note_message				: () -> this.message.replace(/(<[^>]+) style=".*?"/g, '$1')
			created_at_in_words	: () -> format_date(this.created_at) # just use the date...
			created_at_in_date 	: () -> format_date(this.created_at)
			has_subnotes				: () -> true if this._notes && this._notes.length > 0
			draggable						: () -> true unless this._notes && this._notes.length > 0
			subnote_count				: () -> this._notes.length if this._notes
			is_taskable					: () -> true if this.message && this.message.indexOf('#todo') > 0
			has_domains					: () -> true if this._domains && this._domains.length > 0
			domain							: () -> this.url.toLocation().hostname if this.url
			group_colors				: () -> "" #self.group_colors(this)

	#
	# Events
	$(".header-button.menu").onpress (e) ->
		st.toggle_nav()

	$('header .compose').onpress (e) -> 
		st.show_section(new_note, {animation: 'upfrombottom'})

	$('#new-note a.cancel').onpress (e) -> 
		st.show_section(notes_list, {animation: 'downfromtop'})
	
	$('#new-note a.save').onpress (e) -> 
		save_note(); 

	# nav links
	$('a.query').onpress (e) ->
		# reset pagination
		querystring = remove_query_var(document.location.search, 'page')
		window.current_page = 1
		# setup the querystring and navigate it
		param = $(e.currentTarget).attr('data-param')
		value = $(e.currentTarget).attr('data-param-val')

		if value
			url = '/notes.json' + add_or_replace_query_var(querystring, param, value)
		else
			url = '/notes.json' + remove_query_var(querystring, param)
		
		$.getJSON url, (notes) ->
			$('#stage').html render_notes(notes)
			$('.message').autolink() # autolink everything
			st.toggle_nav()

		return false

	#
	# Save new notes
	save_note = () ->
		ajax = $.ajax
			type: 'POST'
			url: "http://#{config.domain}/notes.json"
			data:
				message: $('#new-note textarea').val()
			complete: (data, status, xhr) ->
				$('textarea').val("")
				st.show_section(notes_list, {animation: 'downfromtop'})
		return false

	#
	# Helpers
	format_date = (date) ->
		date = new Date(date)
		return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear()

	#
	# Load notes on page load
	$.getJSON "/notes.json", (notes) ->
		console.log 'test'
		#
		# Load notes into stage
		$('#stage').html render_notes(notes) 
		$('.message').autolink() # autolink everything
	
		