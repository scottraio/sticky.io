class Mob.Routers.Forms extends Backbone.Router
	
	routes:
		"forms"											: "index"
		"/books/:book_id/forms/:id" : "show"
	
	index: ->
		forms 		= new Mob.Collections.Forms()

		forms.pull "forms",
			force: window.refresh
			success: (collection, resp) ->
				index = new Mob.Views.Forms.Index items: forms.toJSON(), el: $("#page")
				index.render()
			error: (resp, error) ->
				console.log error
				
	show: (book_id, id) ->
		fields = new Mob.Collections.FormFields()
		fields.url = url_for("/books/#{book_id}/forms/#{id}.json")
		
		fields.pull id,
			force: window.refresh
			success: (collection, resp) ->
				show = new Mob.Views.Forms.Show items: fields.toJSON(), el: $("#page"), book_id: book_id, id: id
				show.render()
			error: (resp, error) ->
				console.log error