App.Views.Records or= {}

class App.Views.Records.Comments extends Backbone.View
	
	events:
		"focus #new-comment input[type=text]"	: "switch_new_comment_box"
		"click #create-comment"					: "create"
		"click .delete-comment"					: "delete"
	
	initialize: () ->
		#@reset()

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
				
				
				
	create: (e) ->
		self = this
		$.post( $("#new-comment").attr("data-action-url"), { comment: { message: $("#new-comment textarea").val() } }, (data) ->
			$('#new-comment textarea').val("")
			$('#new-comment textarea').blur()
			$(".activity-grid").prepend ich.commentsnip
											data: data
											avatar_url: get_gravatar(data.creator_email, 24)
											actual_date: () ->  $.datepicker.formatDate("mm/dd/yy", new Date(this.created_at))
											time_ago_in_words: () -> $.timeago(this.created_at)
											
			$("#new-comment input[type=text]").show()
			$("#real").addClass("hide")
		, "json")
	
	switch_new_comment_box: (e) ->
		$(e.currentTarget).hide()
		$("#real").removeClass("hide")
		$('#new-comment textarea').focus()
	