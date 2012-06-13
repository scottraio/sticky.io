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
					tags: () -> self.tagify(this.value)
					created_at_in_words: () -> $.timeago(this.value.created_at) if _.isObject(this.value)

				$(self.el).autolink()

	tagify: (mapreduce_value) ->
		if _.isObject(mapreduce_value)
			tags = ""
			for tag in mapreduce_value.tags
				tags += "<a class='hash-tag tag'>##{tag}</a>" 
			tags
		
