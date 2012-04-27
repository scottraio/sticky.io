Mob.Views.Forms or= {}

class Mob.Views.Forms.Index extends Backbone.View
		
	initialize: ->
		mobui.clear()
		
		mobui.set_title("Forms")	
		mobui.add_button("/accounts/1/forms/new")
	
	render: -> 
		$("#content").html ich.navlist
			items: this.options.items 
			url: () -> "/books/#{this.book_id}/forms/#{ this.id }"
			time_ago_in_words: () -> $.timeago(this.created_at)
			title: () -> this.name || "None"
			class: () -> this.name ? "" : "empty"

			
