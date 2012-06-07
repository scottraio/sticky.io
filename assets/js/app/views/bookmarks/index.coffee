App.Views.Bookmarks or= {}

class App.Views.Bookmarks.Index extends Backbone.View
		
	initialize: ->
		@bookmarks = new App.Collections.Bookmarks()

	render: ->
		self = @
		@bookmarks.fetch
			success: (col, bookmarkJSON) ->
				
				$(self.el).html ich.bookmarks_list
					bookmarks: bookmarkJSON

				$(self.el).autolink()
		
