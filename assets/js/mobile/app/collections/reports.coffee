class Mob.Collections.Reports extends Backbone.Collection
	
	model					: Mob.Models.Record
	url						:	url_for("/reports.json")
	localStorage	: new Store(this.url)
	