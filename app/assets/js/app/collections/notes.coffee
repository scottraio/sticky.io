class App.Collections.Notes extends Backbone.Collection

	url: "/notes.json"

	initialize: () ->
		self = @


	parse_for_view: (notes) ->
		for note in notes
			#note.message = note.message.replace(/\n/g, '<br />')
			@format_domains(note) 

	format_domains: (note) ->
		if note._domains		
			for domain in note._domains
				if domain.url
					is_image = domain.url.match /(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i

					if is_image
						@render_image(note, domain)	
					else
						@render_link(note, domain)

	render_image: (note, domain) ->
		note.message 	= note.message.replace domain.url, "<img src=#{domain.url} />"

	render_link: (note, domain) ->
		hostname = domain.url.toLocation().hostname
		note.message 	= note.message.replace domain.url, "<a href='#{domain.url}' target='_blank'><img src='//www.google.com/s2/u/0/favicons?domain=#{hostname}' /> #{domain.title}</a>"

