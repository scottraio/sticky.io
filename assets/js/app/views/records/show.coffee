App.Views.Records or= {}

class App.Views.Records.Show extends Backbone.View
	
	events: _.extend(
		click_or_tap {
			".github-type-select li" : "link_to_tab"
		}, {
			# put default events here
		}
	)

	initialize: -> 	
		reset_events @
		
		$(".record-details").height($("#record").height())
		
		$("div.rich").last().addClass("last-child");
		
		#udo = new App.Views.Records.UserDefinedOrder( _.extend(this.options, action: "show" ) ) if localStorage isnt undefined

		@load_map_if_possible() if $("#canvas").length > 0
		#@get_parascope_upc();
		#@get_parascope_facebook();

		return this

	link_to_tab: (e) ->
		navigate $("a.navigate:first", e.currentTarget).attr("href")
		return false
		
	load_map_if_possible: ->
		try
			# run it async			
			unless $(".plot").length is 0
				_.each $(".plot"), (p) ->
					plot("canvas", $(p).attr("data-lat"), $(p).attr("data-lng"))
			else
				plot("canvas", 38.8447, -99.4922, 2)

			
			
		catch error
			console.log error
	
	get_parascope_upc: ->
		try
			upc = $(".upc:first").attr("data-upc");
			if $(".upc").length isnt 0
				google = new GoogleApi()
				google.upc upc, (data) ->
					if data.items isnt undefined
						$("ul[data-profile=parascope]").append ich.parascopicupc
							image_src: data.items[0].product.images[0].link
							title: data.items[0].product.title
							brand: data.items[0].product.brand
							description: data.items[0].product.description
							price: data.items[0].product.inventories[0].price
							shipping: data.items[0].product.inventories[0].shipping
							link: data.items[0].product.link
						
		catch error
			console.log error
							
	get_parascope_facebook: ->
		try
			email = $(".email:first").attr("data-email");
			if $(".email").length isnt 0
				facebook 	= new Facebook()
				facebook.find email, (user) ->
					$("ul[data-profile=parascope]").append ich.parascopicfacebook
						image: "http://graph.facebook.com/"+user.id+"/picture?type=large"
						user: user
		catch error
			console.log error
			
	move_parascope: ->
		$(".parascope-wrapper").scrollTo(target,500,{axis:'x'});

					
	nav_to_comment: (e) ->
		$("#meta-record").load document.location.pathname + "/comments", () ->
			new App.Views.Records.Comments( el: $("#record-comments") )
		
			
	reset: ->
		$(@el).unbind()
		@delegateEvents()
	
	
		
					
			