App.Views.Users or= {}

class App.Views.Users.Show extends Backbone.View
	
	events: 
		"click .show-all-entries" : "show_all_entries"
	
	initialize: () ->
		self = @
		$.getJSON "/users/#{App.current_user.id}/record_creation_by_book_over_time.json", (data) ->
			self.draw_contribution_chart(data)
			
	show_all_entries: (e) ->
		link = $(e.currentTarget)
		$("li[data-record-id=#{link.attr("rel")}]").removeClass("hidden")
		link.parent("li").hide()

	draw_contribution_chart: (data) ->
		self = @
		categories = @categories
		
		new Highcharts.Chart({
			chart:
				renderTo: 'contribution_chart'
				backgroundColor: "transparent"
				defaultSeriesType: 'area'
			plotOptions:
				area:
					marker:
						enabled: false
						symbol: 'circle'
						radius: 2
						states:
							hover:
								enabled: true
					dataLabels:
						enabled: false
			credits:
				enabled: false
			title:
				text: "Record creation for the Past 30 days"
			xAxis:
				gridLineColor: "#EEEEEE"
				#categories: categories(data)
			yAxis:
				allowDecimals: false
				plotLines: [
            		value: 0
            		width: 1
            		color: '#808080'
            	]
			tooltip: () ->
				return '' + this.x +': '+ Highcharts.numberFormat(this.y, 0, ',') +' records'
			legend:
            	borderWidth:0
			series: data
		})

	categories: (data) ->
		arr = []
		for datum in data
			arr << data[0]
		return arr


