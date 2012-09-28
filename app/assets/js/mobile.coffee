#= require ./mobile/zepto.js
#= require ./vendor/icanhaz.js
#= require ./mobile/sidetap.js
#= require ./app/helpers/app.coffee

domain = "sticky.io"

$(document).ready () ->

	st = sidetap()

	# 
	# Get notes
	render_notes = (url, cb) ->
		$.getJSON url, (notes) ->
			$('#stage').html ich.notes_board
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

				cb() if cb

	#
	# Events
	new_note = $('#new-note')
	notes_list = $('#notes-list')

	$(".header-button.menu").on("click",st.toggle_nav)
	$('header .compose').click () -> st.show_section(new_note, {animation: 'upfrombottom'})
	$('#new-note a.cancel').click () -> st.show_section(notes_list, {animation: 'downfromtop'})
	$('#new-note a.save').click () -> save_note(); 

	#
	# Save new notes
	save_note = () ->
		ajax = $.ajax
			type: 'POST'
			url: "http://#{domain}/notes.json"
			data:
				message: $('#new-note textarea').val()
			complete: (data, status, xhr) ->
				render_notes () ->
					st.show_section(notes_list, {animation: 'downfromtop'})
		return false

	#
	# Load notes on page load
	render_notes '/notes.json', () ->
		$('a.query').click (e) ->
			# reset pagination
			querystring = remove_query_var(document.location.search, 'page')
			window.current_page = 1
			# setup the querystring and navigate it
			param = $(e.currentTarget).attr('data-param')
			value = $(e.currentTarget).attr('data-param-val')
			if value
				render_notes '/notes.json' + add_or_replace_query_var(querystring, param, value)
			else
				render_notes '/notes.json' + remove_query_var(querystring, param)
			
			st.toggle_nav()
		