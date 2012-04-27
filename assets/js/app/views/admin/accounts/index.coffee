App.Views.Admin or= {}
App.Views.Admin.Accounts or= {}

class App.Views.Admin.Accounts.Index extends Backbone.View

	initialize: ->
		#self = @
		#$.getJSON document.location + "/dbstats.json", (data) ->
		#	self.draw_db_stats_chart(data)
		

	draw_db_stats_chart: (data) ->
		self = @

		new Highcharts.Chart({
			chart:
				renderTo: 'dbstats_chart'
				backgroundColor: "transparent"
				defaultSeriesType: 'column'
			credits:
				enabled: false
			title:
				text: "Database Stats"
			xAxis:
				gridLineColor: "#EEEEEE"
				categories: ['Average Record Size', 'Index Size']
			yAxis:
				allowDecimals: false
				plotLines: [
	        		value: 0
	        		width: 1
	        		color: '#EEEEEE'
	        	]
			tooltip: () ->
				return '' + this.x +': '+ Highcharts.numberFormat(this.y, 0, ',') +' records'
			legend:
	        	borderWidth:0
			series: [{
         		name: 'size in MB',
         		data: [(data.avgObjSize / 1024), (data.indexSize / 1024)]
         	}]
		})