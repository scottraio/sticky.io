window.Mob 				= {}
Mob.Routers	 			= {}
Mob.Models 				= {}
Mob.Collections 	= {}
Mob.Views 				= {}

# app bootstrapping on document ready
$(document).ready () ->

	Mob.initialize = () ->
		
		
		# load the routers + utlity views
		new Mob.Views.Main({ el: $("body") })
		new Mob.Views.Navigation({ el: $("#tabbar") })
		new Mob.Views.ListView({ el: $("#content") })
		
		main = new Mob.Routers.Home()
		new Mob.Routers.Forms()
		new Mob.Routers.Reports()
		new Mob.Routers.Records()
		
		main.navigate 'm#reports', true if Backbone.history.getFragment() is ''
			
		setTimeout( () ->
			window.scroller.enable("wrapper")
		, 1000)
	
	window.scroller = new Mob.Views.Scrollview()
	window.scroller.set_height()
	
	Mob.initialize()
	Backbone.history.start()


Backbone.Collection.prototype.pull = (id, options) ->
	self 							= this

	self.localStorage	= new Store("wm-#{id}")
	records 					= self.localStorage.records
	store							= self.localStorage
	

	if records.length is 0 or options.force
		$.getJSON self.url, (data) ->	
			console.log "grabbed"
			if _.isArray(data)
				for item in data
					create_or_update(store, item)
			else
				create_or_update(store, data)

			self.fetch(options)
	else	
		self.fetch(options)

create_or_update = (store, data) ->
	if store.find(data)
		store.update(data) 
	else
		store.create(data)
	
