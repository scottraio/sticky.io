class App.Models.Group extends Backbone.Model

	url: () ->
		if this.isNew()
			"/notebooks.json"
		else
			"/notebooks/" + this.id + ".json"