App.Views.Notes or= {}

class App.Views.Notes.Index extends Backbone.View
	
	events: 
		'click .card-info' : 'navigate'
		'click .navigate'  : 'navigate'
	
	initialize: ->
		@notes 		= new App.Collections.Notes()
		@filters  	= @options.tags

	render: (type) ->
		self = @
		@notes.fetch 
			success: (col, items) ->
				switch type
					when 'list'
						self.render_list(items)
					when 'grouped'
						self.render_grouped(items)
					when 'board'
						self.render_board(items)	
						self.auto_image_resolution(items)
					

	render_list: (items) ->
		self = @
		$('#stage').html ich.notes_list
			filters: self.filters || "All"
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)
		$('.autolink').autolink()
		
	render_board: (items) ->
		$('#stage').html ich.notes_board
			filters: self.filters || "All"
			notes: items
			created_at_in_words: () -> $.timeago(this.created_at)
		$('.autolink').autolink()

	render_grouped: (items) ->
		self = @
		tags = new App.Collections.Tags()

		tags.fetch
			success: (col, tagsJSON) ->
				
				$('#stage').html ich.notes_grouped
					tags 				: tagsJSON 
					notes_by_tag 		: () -> self.notes_by_tag(this,items)
					created_at_in_words : () -> $.timeago(this.created_at)
					
				$('.autolink').autolink()				
	
	notes_by_tag: (tag, items) ->
		notes = "<li class=\"sticky card\">"

		for item in items
			notes += "<div><div class=\"autolink\">#{item.message}</div></div>" if item.tags.indexOf(tag._id) isnt -1
		
		notes += "</li>"	
		
		return notes


	show_note_details: (e) ->
		id = $(e.currentTarget).attr('data-id')
		navigate "/notes/#{id}"

	navigate: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false


	auto_image_resolution: (notes) ->
		for note in notes
			for link in note.links
				matched = link.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i
				if matched
					$("li[data-id='#{note._id}']").prepend "<img src=#{matched[0]} />"

		$('.autolink').remove_img_links()

		
 		
