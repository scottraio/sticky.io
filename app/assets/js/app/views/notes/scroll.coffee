App.Views.Notes or= {}

class App.Views.Notes.Scroll
	
	initialize: () ->
		@end_of_page 	= false
		@reset				= false
		@at_header 		= false
		@anchor_expanded_view = false
		@at_default_position = false

	bind: (view) ->
		$(window).unbind('scroll')

		self 					= @
		@current_page = 1

		# the notes index view that we attach to the scroll object
		@view 				= view

		$(window).scroll () ->
			pos 					= $(window).scrollTop()
			height 				= $(this).outerHeight()
			scrollheight 	= document.body.scrollHeight

			# If we're at the bottom, show the overlay and retrieve the next page
			if self.view.notes && self.view.notes.length >= 25 && (scrollheight - (pos + 100) <= height)
				self.end_of_page = true 
			else
				self.end_of_page = false

			# We check if we're at the bottom of the scrollcontainer
			#if ($(this)[0].scrollHeight - $(this).scrollTop() == $(this).outerHeight())
			if pos > 50 
				self.at_header = true 
				self.do_anchor_expanded_view() if scrollheight > pos + height
			else
				# reset if we scroll all the way to the top
				self.reset = true 

			if pos < 75
				self.do_at_default()
		
		setInterval(() ->
			self.do_end_of_page() 					if self.end_of_page
			self.do_at_header() 						if self.at_header
			self.do_anchor_expanded_view() 	if self.anchor_expanded_view
			self.do_reset() 								if self.reset		
		, 100)

	do_end_of_page: () ->
		#return false if @view.notes && @view.notes.length is 0
		@end_of_page 	= false

		# we lock paginating while loading results
		unless @lock	
			@current_page += 1
			@view.load_page(@current_page)

	do_at_header: () ->
		@at_header = false
		$('#new-sticky-header').css('top', '-45px')

	do_reset: () ->
		@reset = false
		$('#new-sticky-header').css('top', '0')

	do_at_default: () ->
		if $('#expanded-view').hasClass('top')
			$('#expanded-view').removeClass('top')

	do_anchor_expanded_view: () ->
		@anchor_expanded_view = false
		#height 	= $('body').height() - $('#expanded-wrapper').outerHeight() - $('#expanded-actions').outerHeight() - 210
		#width 	= $('#expanded-view').width()

		$('#expanded-view').addClass('top') unless $('#expanded-view').hasClass('top')



