class Mob.Routers.Home extends Backbone.Router
  
	routes:
    "home": "index"

  index: ->
		home = new Mob.Views.Home({ el: $("content") })
		home.render()
