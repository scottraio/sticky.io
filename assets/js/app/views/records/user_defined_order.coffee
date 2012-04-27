App.Views.Records ||= {}

class App.Views.Records.UserDefinedOrder extends Backbone.View
	
	initialize: ->
		# user defined sort order
		@superkey = "/books/#{ this.options.book_id }/users/#{ current_user("id") }"
		this.acts_as_sortable() if this.options.action is "show"
		this.arrange()
	
	acts_as_sortable: ->
		superkey = @superkey
		$("#user_layout").sortable
			opacity: 0.95,
			update: (event, li) ->
				localStorage.setItem(superkey,JSON.stringify($("#user_layout").sortable('toArray')))
		return this

	arrange: ->
		mem = memory(this.superkey)
		unless $.isEmptyObject(mem)
			$('#user_layout li.udo').sortElements (a,b) -> 
			    return mem.indexOf($(a).attr("id")) > mem.indexOf($(b).attr("id")) ? 1 : -1;
		return this
