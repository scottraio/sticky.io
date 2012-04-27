App.Views.Shared or= {}

class App.Views.Shared.BookIcons extends Backbone.View
	
	events:
		"click li" : "select" 
	
	initialize: ->
		@icons = _.range(58)
		
	render: ->
		this.el.html ich.book_icons
			icons: @icons
		current_icon = this.el.prev("input").val()
		$("li[rel=#{current_icon}]", this.el).addClass("selected")
			
	select: (e) ->
		li = $(e.currentTarget)
		# give it the selected class
		$("li", this.el).removeClass("selected")
		li.addClass("selected")
		# change the hidden input
		this.el.prev("input").val(li.attr("rel"))