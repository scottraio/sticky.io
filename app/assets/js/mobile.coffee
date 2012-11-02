#= require ./vendor/modernizr.js
#= require ./mobile/zepto.js
#= require ./mobile/zepto.fasttap.js
#= require ./mobile/mbp.js
#= require ./vendor/icanhaz.js
#= require ./mobile/sidetap.js
#= require ./app/helpers/app.coffee
#= require ./app/helpers/mixins.coffee

$(document).ready () ->

	new_note 			= $('#new-note')
	show_note 		= $('#show-note')
	notes_list 		= $('#notes-list')

	#
	# Connect to Socket.IO
	socket.on 'notes:add', (data) ->
		#
		# Render the view
		$('ul.notes_board:first-child').before render_notes([data])
		bind_onpress_to_note('ul.notes_board:first-child li.sticky')


	#
	# Start Sidetap
	st = sidetap()

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
	# Load notes
	load_notes = (url) ->
		url = "/notes.json" unless url
		#
		# Load notes on page load
		$.getJSON url, (notes) ->
			#
			# Load notes into stage
			$('#stage').html render_notes(notes) 

			$('.message').autolink() # autolink everything

			bind_onpress_to_note('li.sticky')

	#
	# Show note
	load_note = (id) ->
		st.show_section(show_note, {animation: 'infromright'})
		
		url = "/notes/#{id}/expanded.json"

		$.getJSON url, (notesJSON) ->
			notes = []
			for note in notesJSON
				if note._id is id
					parent = note
				else
					notes.push note

			$('#expanded-view').html render_note(parent, notes)

				

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

	render_note = (parent, notes) ->
		ich.expanded_note
			parent_note 				: parent
			notes 							: notes
			note_message 				: () -> this.message && this.message.replace(/(<[^>]+) style=".*?"/g, '$1')
			has_subnotes				: () -> true
			stacked_at_in_words	: () -> format_date(this.stacked_at)
			stacked_at_in_date 	: () -> format_date(this.stacked_at)

	#
	# Events
	$(".header-button.menu").onpress (e) ->
		st.toggle_nav()

	$('header .compose').onpress (e) -> 
		st.show_section(new_note, {animation: 'upfrombottom'})
	
	$('#new-note a.save').onpress (e) -> 
		save_note(); 

	$('#new-note .cancel').onpress (e) -> 
		st.show_section(notes_list, {animation: 'downfromtop'}) # cancel button needs to know how to animate back to notes
		hide_keyboard()

	$('#show-note .cancel').onpress (e) -> 
		st.show_section(notes_list, {animation: 'infromleft'}) # cancel button needs to know how to animate back to notes
		hide_keyboard()

	bind_onpress_to_note = (selector) ->
		$(selector).onpress (e) -> 
			note_id = $(e.currentTarget).attr('data-id')
			load_note(note_id)

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
		
		load_notes(url)
		st.toggle_nav()
		
		return false

	#
	# Helpers
	format_date = (date) ->
		date = new Date(date)
		return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear()


	hide_keyboard = () ->
		document.activeElement.blur()
		$("input").blur()
		$("div[editablecontent=true]").blur()


	#
	# Load notes on page load
	load_notes()

	st.show_section(new_note, {animation: 'upfrombottom'})


	
	
		