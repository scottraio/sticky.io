App.Views.Users or= {}

class App.Views.Users.ConnectWith extends Backbone.View
	
	events: 
		"click .connect_to_facebook" 	: "connect_to_facebook"
		"click .connect_to_linkedin" 	: "connect_to_linkedin"
		"click .connect_to_twitter"		: "connect_to_twitter"
		"click .connect_to_google" 		: "connect_to_google"
	
	initialize: ->	

	
	#
	# Setup easy access methods to services such as facebook, linkedin, twitter, and google
	#
	
	facebook: ->
		new Facebook()
		
	linkedin: ->
		new LinkedIn()
		
	twitter: ->
		new Twitter()
	
	google: ->
		new Google()

	#
	# Show that services are connected with the enable methods
	#

	enable_service: (type) ->
		$("##{type}").attr("checked", true)
		$(".connect_to_#{type} span").removeClass("i16_#{type}")
		$(".connect_to_#{type} span").addClass("i16_#{type}_on")
		$(".connect_to_#{type} label.info").addClass("connected")

	enable_facebook: ->
		if @facebook().logged_in() 
			@enable_service("facebook")
			@facebook().name (name) ->
				$(".connect_to_facebook label.info small").html("Connected as " + name)
		
	enable_linkedin: ->
		if @linkedin().logged_in()
			@enable_service("linkedin")
			@linkedin().name (name) ->
				$(".connect_to_linkedin label.info small").html("Connected as " + name)
		
	enable_twitter: ->
		if @twitter().logged_in()
			@enable_service("twitter")
	
	#
	# If we're not connected, lets get connected		
	#
	
	connect_to_facebook: (e) ->
		if $("#facebook:checked").length isnt 0
			@facebook().authorize()

	connect_to_twitter: (e) ->
		if $("#linkedin:checked").length isnt 0
			@twitter().authorize()

	connect_to_linkedin: (e) ->
		if $("#linkedin:checked").length isnt 0
			@linkedin().authorize()
			
	connect_to_google: (e) ->
		if $("#google:checked").length isnt 0
			@google().authorize()