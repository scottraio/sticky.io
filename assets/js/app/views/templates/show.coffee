App.Views.Templates or= {}

class App.Views.Templates.Show extends Backbone.View

	
	events:
		"click ul.categories .link"	: "load_category"
		"click .enlarge" 			: "load_screenshot"
		"click .install"			: "install"
		
	initialize: ->
		# pusher service
		@pusher 	= new Pusher('b4313c9fce9dd78da159');
		@channel 	= @pusher.subscribe('template_install_progress');
		
		$( "#progressbar" ).progressbar
			value: 1
			complete: (event, ui) ->				
				$(".ui-progressbar .ui-widget-header").addClass("complete")
				location.href = "/templates/finished"
				
		
	load_category: (e) ->
		li = $(e.currentTarget)
		remote_get("#stage", "/templates?category_id=#{li.attr('rel')}", true)
		return false

	load_screenshot: (e) ->
		$.facebox
			image: $(e.currentTarget).attr("rel")
		return false
		
	install: (e) ->
		$( "#progressbar" ).show()
		$(e.currentTarget).hide()
		self = this
		ajax = $.ajax
			type: "POST"
			data: {_method: "put"}
			url: $(e.currentTarget).parents("form").attr("action")
			dataType: "json"
			success: (data, status, xhr) ->
				self.channel.bind "job_#{data.id}", (data) ->
					$("#progressbar .ui-progressbar-value").animate 
						width: "#{data}%"
						queue: false
						() ->
							$( "#progressbar" ).progressbar("value", data)
				
		return false
		
		