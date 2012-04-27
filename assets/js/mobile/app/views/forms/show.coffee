Mob.Views.Forms or= {}

class Mob.Views.Forms.Show extends Backbone.View

	initialize: ->
		mobui.clear()
		
		mobui.back_button("Back")

	render: -> 
		$("#content").html ich.formshow
			items: 						this.options.items
			post_to_records: 	url_for("/books/#{this.options.book_id}/records.json")
			textbox: 		() -> true if this.field_type is "textbox"
			numeric: 		() -> true if this.field_type is "numeric"
			money: 			() -> true if this.field_type is "money"
			email: 			() -> true if this.field_type is "email"
			select: 		() -> true if this.field_type is "select"
			phone: 			() -> true if this.field_type is "phone_number"
			paragraph: 	() -> true if this.field_type is "textarea"
	
		