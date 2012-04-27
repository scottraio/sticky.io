App.Views.Shared or= {}

class App.Views.Shared.SelectABook extends Backbone.View
		
	events:
		"click li"				: "select_book"
		"click .scroll-right" 	: "scroll_right"
		"click .scroll-left"	: "scroll_left"

	initialize: ->
		self = @

		current_icon = $("#book_icon_id").val()
		$("li[rel=#{current_icon}]", @options.target).addClass("active")

		if @is_overflowed()
			@options.target.parents("span.field:first").prepend("<div class='scroll-right'><span class='icon16 i16_arrow_left'></span></div>")

		@options.target.scroll () ->
			self.show_hide_controls()			
				
	select_book: (e) ->
		$("li", @options.target).removeClass("active")
		$(e.currentTarget).addClass("active")
		$("#book_icon_id").val($(e.currentTarget).attr("rel"))

	is_overflowed: ->
		return @options.target[0].scrollWidth > @options.target[0].offsetWidth

	is_absolute_left: ->
		return @options.target[0].scrollLeft is 0

	is_absolute_right: ->
		return @options.target.width() + @options.target[0].scrollLeft is @options.target[0].scrollWidth
	
	scroll_left: (e) ->
		leftPos = @options.target.scrollLeft()
		@options.target.animate({scrollLeft: leftPos - 200}, 200)

	scroll_right: (e) ->
		leftPos = @options.target.scrollLeft()
		@options.target.animate({scrollLeft: leftPos + 200}, 200)

	show_hide_controls: () ->
		if @is_overflowed() 
			if @is_absolute_right()
				$("div.scroll-right").remove()
			else
				if $("div.scroll-right").length is 0 
					@options.target.parents("span.field").append("<div class='scroll-right'><span class='icon16 i16_arrow_left'></span></div>")

			if @is_absolute_left()
				$("div.scroll-left").remove()
			else
				if $("div.scroll-left").length is 0 
					@options.target.parents("span.field").append("<div class='scroll-left'><span class='icon16 i16_arrow_right'></span></div>")

