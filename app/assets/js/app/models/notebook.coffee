class App.Models.Notebook extends Backbone.Model

	url: () ->
		if this.isNew()
			"/notebooks.json"
		else
			"/notebooks/" + this.id + ".json"
