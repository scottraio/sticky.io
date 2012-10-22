Schema 			= mongoose.Schema
Base 				= require 'sticky-model'
phantom			= require 'phantom'

DomainSchema = new Schema
	url  				: { type: String, required: true, trim: true, unique: true}
	title				: { type: String, required: true, trim: true}

DomainSchema.path('url').validate Base.uniqueFieldInsensitive('Domain', 'url'), 'unique'

DomainSchema.methods.crawl = (link, note, cb) ->
	self = this
	self.set 'url', link
	
	app.models.Domain.where('url', link).limit(1).run (not_found, domain) ->
		if domain[0]
			unless domain[0].title
				domain[0].set_title (err, dom) ->
					cb(err, dom)
			else
				cb(not_found, domain[0])			
		else
			self.set_title (err, dom) ->
				cb(err, dom)

DomainSchema.methods.set_title = (cb) ->
	self = @
	@get_title (title) ->
		self.set 'title', title
		self.save (err) ->
			cb(err, self)

DomainSchema.methods.get_title = (cb) ->
	self = @
	phantom.create (ph) ->
		ph.createPage (page) ->
			page.open self.url, (status) ->
				page.evaluate (-> document.title), (result) ->
					ph.exit()
					cb(result)
						
						


mongoose.model('Domain', DomainSchema)
