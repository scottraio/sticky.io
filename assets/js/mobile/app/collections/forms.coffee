class Mob.Collections.Forms extends Backbone.Collection
	
	model					: Mob.Models.Form
	url						: url_for("/forms.json")
	