class Mob.Routers.Reports extends Backbone.Router
	
	routes:
		"reports"				: "index"
		"/reports/:id" 	: "show"
	
	index: ->		
		reports 		= new Mob.Collections.Reports()
		
		reports.pull "reports",
			force: window.refresh
			success: (collection, resp) ->
				index = new Mob.Views.Reports.Index items: reports.toJSON(), el: $("#page")
				index.render()
			error: (resp, error) ->
				console.log error	
				
	show: (id) ->
		records 		= new Mob.Collections.Records()
		records.url = url_for("/reports/#{id}.json")
		
		records.pull "records-#{id}", 
			force: window.refresh
			success: (collection, resp) ->
				show = new Mob.Views.Reports.Show items: records.toJSON(), el: $("#page"), id: id
				show.render()
			error: (resp, error) ->
				console.log error