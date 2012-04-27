class Mob.Views.Scrollview extends Backbone.View

	initialize: ->
		document.addEventListener 'touchmove', (e) ->
			 e.preventDefault()
		,false
	
	enable: (el) ->
		self = this
		@pulldown = $("#pull-down")
		@pullup		= $("#pull-up")
		
		window.scrollview = new iScroll el, 
			checkDOMChanges: true
			useTransition: true
			topOffset: $("#pull-down").height()
			onBeforeScrollStart: (e) ->
				target = e.target
				#while (target.nodeType isnt 1) target = target.parentNode
				e.preventDefault() if (target.tagName != 'SELECT' && target.tagName != 'INPUT' && target.tagName != 'TEXTAREA')
				    
			onRefresh: () ->
				self.on_refresh()
				
			onScrollMove: () ->
				if this.y > 5 and not self.pulldown.hasClass('flip')
					self.flip()
					this.minScrollY = 0
				else if this.y < 5 and self.pulldown.hasClass('flip')
					self.release()
					this.minScrollY = -self.pulldown.height()
					
			onScrollEnd: () ->
				self.on_scroll_end()
	
	set_height: ->
		height = window.innerHeight - $('header').height() - $('tabbar').height() - $("section#sub-header").height()
		$('#wrapper').css "height", height + 'px'
		
	flip: () ->
		$("#pull-down").addClass('flip')
		$("#pull-down label").html 'Release to refresh...'
		
	release: () ->
		$("#pull-down").removeClass('flip')
		$("#pull-down label").html "Pull down to refresh..."
		
	on_refresh: () ->
		if $("#pull-down").hasClass("loading")
			$("#pull-down").removeClass("loading")
			$("#pull-down label").html 'Pull down to refresh...'
			console.log "test"
			
	on_scroll_end: () ->
		if $("#pull-down").hasClass('flip')
			$("#pull-down").addClass("loading")
			$("#pull-down label").html 'Loading...'
			
			window.refresh = true
			Backbone.history.loadUrl(window.location.hash.substr(1))
			window.refresh = false
			
			
			