Schema 			= mongoose.Schema
Base 				= require 'sticky-model'
phantom			= require 'phantom'

DomainSchema = new Schema
	url  				: { type: String, required: true, trim: true, unique: true}
	title				: { type: String, required: true, trim: true}


DomainSchema.methods.crawl = (link, note, cb) ->
	self = this
	self.set 'url', link

	phantom.create (ph) ->
		ph.createPage (page) ->
			page.open link, (status) ->
				page.evaluate (-> document.title), (result) ->
					self.set 'title', result
					self.save (err) ->
						ph.exit()
						if err
							app.models.Domain.where('url', link).limit(1).run (err, domain) ->
								cb(err, domain[0])
						else
							cb(err, self)

mongoose.model('Domain', DomainSchema)
