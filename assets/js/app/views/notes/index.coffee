App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events: 
		'dblclick .sticky' 						: 'edit'
		'click .delete'  						: 'delete'
		'click .dropdown-menu .color-choice'  	: 'update_color'
	
	initialize: ->
		@params		= @options.params
		@notes 		= new App.Collections.Notes()

		# set the url to the search query, if there is a search query
		if window.location.search
			@notes.url 	= window.location.pathname + ".json" + window.location.search

	render: (items) ->
		self = @
		@notes.fetch 
			success: (col, items) ->
				self.load_view(items)	

	load_view: (items) ->
		self = @ 

		# setup the notes_board
		$('#stage').html ich.notes_board
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)

		# autolink everything
		$('.autolink').autolink()

		# add the sidebar
		#
		
		#$('#notebooks li').each (i, notebook) ->		
		#	self.acts_as_droppable(notebook)

		#$('#stage ul.notes_board li').each (i, sticky) ->
		#	self.acts_as_draggable(sticky)


    	# make it stackable
		#$("ul.notes_board li.sticky").droppable
		#	over: (event, ui) ->
		#		$li = $(this)
		#		self.t = setTimeout () ->
		#			$li.addClass("stack")
		#		, 1500
		#	out: (event, ui) ->
		#		clearTimeout(self.t)
		#		$("ul.notes_board li.sticky").removeClass('stack')
		#	drop: (event, ui) ->
		#		clearTimeout(self.t)
		#		if $(this).hasClass('stack')
		#			$(ui.draggable[0]).hide()
		#			$(this).addClass('deck')
		#		$("ul.notes_board li.sticky").removeClass('stack')

		# make it sortable
		#$("ul.notes_board li.sticky").draggable
		#	revert: true

		# resolve any images
		@auto_image_resolution(items)

	
	edit: (e) ->
		id = $(e.currentTarget).attr('data-id')
		push_url "/notes/#{id}/edit"


	delete: (e) ->
		self = @
		sticky = $(e.currentTarget).parent('.sticky')
		note = new App.Models.Note(id: sticky.attr('data-id'))
		note.destroy
			success: (model, res) ->
				$(sticky).remove()
		return false

	update_color: (e) ->
		color 	= $(e.currentTarget).attr('data-color')
		note 	= new App.Models.Note(id: $(e.currentTarget).parents('.sticky').attr('data-id'))

		save note, {color: color}
			success: (data, res) ->
				meta = $(e.currentTarget).parents('div.meta')
				meta.removeClass()
				meta.addClass('meta')
				meta.addClass(color)

				color_box = meta.children('.color-choice:first')
				color_box.removeClass()
				color_box.addClass('color-choice')
				color_box.addClass(color)

				console.log meta
				console.log color_box
			error: (data, res) ->
				console.log 'error'

	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()

	acts_as_droppable: (li) ->
		li.addEventListener 'drop', (e) ->
			# this / e.target is current target element.
			if e.stopPropagation
				e.stopPropagation() # stops the browser from redirecting.
			
			# source 
			source_id = e.dataTransfer.getData('Text')
			#$("li[data-id=#{source_id}]").remove()

			# target
			#unless $(this).attr('data-id') is source_id
				#@=$(this).removeClass('stack')

			return false
		, false

		li.addEventListener 'dragenter', (e) ->
			$(this).addClass('active')
			return false
		, false

		li.addEventListener 'dragover', (e) ->
			# Necessary. Allows us to drop.
			e.preventDefault() if e.preventDefault
			e.dataTransfer.dropEffect = 'copy';
			$(this).addClass('active')
		, false

		li.addEventListener 'dragleave', (e) ->
			$(this).removeClass('active') # this / e.target is previous target element.
		, false


	acts_as_draggable: (li) ->
		self = @

		li.setAttribute('draggable', 'true')

		li.addEventListener 'dragstart', (e) ->
			e.dataTransfer.effectAllowed = 'copy' # only dropEffect='copy' will be dropable
			e.dataTransfer.setData('Text', $(e.currentTarget).attr('data-id')) 
			this.style.opacity = '0.4'
			$("#notebooks").show()
		, false

		li.addEventListener 'dragend', (e) ->
			#_.each $("ul.notes_board li.sticky"), (dragger) ->
			#	$(dragger).attr("draggable", true) unless li is dragger

			#_.each $("ul.notes_board li.sticky"), (li) ->
			#	$(li).removeClass('stack')
			$("#notebooks").hide()
			this.style.opacity = '1'
		, false

		
