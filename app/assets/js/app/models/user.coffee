class App.Models.User extends Backbone.Model

	url: () ->
		if this.isNew()
			"/users.json"
		else
			"/users/" + this.id + ".json"
	

