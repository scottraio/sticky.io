class Mob.Routers.Records extends Backbone.Router
	
	routes:
		"/reports/:report_id/records/:id" : "show"
				
	show: (report_id, id) ->
		record 			= new Mob.Collections.Records()
		record.url 	= url_for("/reports/#{report_id}/records/#{id}.json")
		
		record.pull "records-#{id}",
			force: window.refresh
			success: (collection, resp) ->
				show = new Mob.Views.Records.Show({ item: record.get(id).toJSON(), el: $("#page") })
				show.render()
			error: (resp, error) ->
				console.log error

			