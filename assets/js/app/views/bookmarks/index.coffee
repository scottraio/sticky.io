App.Views.Bookmarks or= {}

class App.Views.Bookmarks.Index extends Backbone.View
		
	initialize: ->
		@bookmarks = new App.Collections.Bookmarks()

	render: ->
		self = @
		@bookmarks.fetch
			success: (col, bookmarkJSON) ->
				console.log bookmarkJSON

				$(self.el).html ich.bookmarks_list
					bookmarks: bookmarkJSON
					tags: () -> 
						tags = ""
						for tag in this.value.tags
							tags += "<a class='hash-tag tag'>##{tag}</a>"
						tags
					created_at_in_words: () -> this.value.created_at

				$(self.el).autolink()
		
