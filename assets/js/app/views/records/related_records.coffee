App.Views.Records or= {}

class App.Views.Records.RelatedRecords extends Backbone.View
	
	events: 
		"click input[type=submit]"		: "create"
		"click .delete-related"			: "delete"
	
	initialize: ->
		reset_events @
		#@autocomplete = new App.Views.Records.RelatedSearch(selector: $("#report_keyword"), report_id: $('select#report_id').val())
	
	render: () ->
		self = this
				
	create: (e) ->
		self = this
		$.post( $("#new-related-record").attr("data-action-url"), $(".related-search-controls form").serialize(), (data) ->
			_.each data, (item) ->
				$("#related-record h1.empty").hide()
				$("#report_keyword").val("")
				$(".related-search-controls form").hide()
				$(".relate-the-following span").remove()
				$(".related-records").prepend self.cell(data)

		, "json")
		return false
		
	delete: (e) ->
		$link = $(e.currentTarget)
		t = setTimeout('loading(true)', 4000)
		close_all_pops()
		ajax = $.ajax
			type: "POST"
			url: $link.attr("href")
			data: {_method: "DELETE"}
			dataType: "json"
			success: (data, status, xhr) ->
				$link.parents("li").hide()
				loading(false)
				clearTimeout(t)
		return false

	cell: (data) ->
		self = this
		ich.recordsnip
			data: data
			record_id: self.options.record_id
			actual_date: () ->  $.datepicker.formatDate("mm/dd/yy", new Date(this.created_at))
			time_ago_in_words: () -> $.timeago(this.created_at)
	
	
	