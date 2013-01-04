class App.Sockets

	set_view: (data) ->
		@view 				= new App.Views.Notes.Index()	
		@view.notes 	= [data]
		@view.ui_before_hook()

	listen: ->
		self = @
		# 
		# Socket.IO
		socket.on 'notes:add', (data) ->
			self.add_note(data)
			
		# 
		# Socket.IO
		socket.on 'notes:update', (data) ->
			self.update_note(data)

	add_note: (data) ->
		@set_view(data)
		
		#
		# Render the view
		$('ul.notes_board:first-child').before @view.ich_notes()
		# remove the empty notes
		$('ul.notes_board li.empty').hide() if $('ul.notes_board li.empty').length > 0
		# auto-link everything
		$('ul.notes_board:first-child li .message').autolink()
		# DnD
		window.dnd.draggable $('ul.notes_board:first-child li')
		window.dnd.droppable $('ul.notes_board:first-child li')

	update_note: (data) ->
		@set_view(data)

		#
		# Render the view
		template = Handlebars.compile('{{>sticky}}')
		html = template(data)
		$("ul.notes_board li[data-id=#{data._id}]").html(html)
		$('ul.notes_board li[data-id=#{data._id}] .message').autolink()