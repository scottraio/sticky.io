#_.extend Backbone.Collection.prototype, Backbone.Events, 
#	all: (fragment) ->
#		this.url = fragment
#		this.fetch()
#		return this

$.fn.hasAncestor = (a) ->
	return this.filter () ->
		return !!$(this).closest(a).length

String.prototype.contains = (it) -> return this.indexOf(it) != -1

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

$.fn.serializeObject = () ->
	o = {}
	a = this.serializeArray()
	$.each a, () ->
		if o[this.name] isnt undefined
			if !o[this.name].push
				o[this.name] = [o[this.name]]
			o[this.name].push(this.value || '')
		else
			o[this.name] = this.value || ''
	return o

$.fn.autolink = () ->
	return this.each( () ->
		$(this).html( $(this).html().replace(match.link, "<a href='$1' target='_blank'>$1</a>") )
		$(this).html( $(this).html().replace(match.tag, ' <a data-tag-name="$2" class="hash-tag tag">&#35;$2</a>') )
		$(this).html( $(this).html().replace(match.group, ' <a href="/notes?notebooks[]=$2" class="group-link navigate">@$2</a>') )
	)

$.fn.remove_img_links = () ->
	return this.each( () ->
		$(this).html( $(this).html().replace(/(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i, "") )
	)	
