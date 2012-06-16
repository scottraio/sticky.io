class App.Models.Group extends Backbone.Model

	url: () ->
		if this.isNew()
			"/groups.json"
		else
			"/groups/" + this.id + ".json"