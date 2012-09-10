class App.Models.Note extends Backbone.Model

	url: () ->
		if this.isNew()
			"/notes.json"
		else
			"/notes/" + this.id + ".json"
	

