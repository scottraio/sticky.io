class App.Collections.Notes extends Backbone.Collection

	url: "/notes.json"

	initialize: () ->
		self = @

	format_domains: (notes) ->	
		for note in notes
			note.message = note.message.replace(/\n/g, '<br />')
			if note._domains
				for domain in note._domains
					if domain.url
						hostname 			= domain.url.toLocation().hostname
						note.message 	= note.message.replace domain.url, "<a href='#{domain.url}' target='_blank'><img src='//www.google.com/s2/u/0/favicons?domain=#{hostname}' /> #{domain.title}</a>"

