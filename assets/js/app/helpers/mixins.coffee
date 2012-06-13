#_.extend Backbone.Collection.prototype, Backbone.Events, 
#	all: (fragment) ->
#		this.url = fragment
#		this.fetch()
#		return this

$.fn.hasAncestor = (a) ->
	return this.filter () ->
		return !!$(this).closest(a).length

String.prototype.contains = (it) -> return this.indexOf(it) != -1

$.fn.autolink = () ->
	return this.each( () ->
		$(this).html( $(this).html().replace(match.link, "<a href='$1' target='_blank'>$1</a>") )
		$(this).html( $(this).html().replace(match.tag, ' <a data-tag-name="$2" class="hash-tag tag">&#35;$2</a>') )
	)

$.fn.remove_img_links = () ->
	return this.each( () ->
		$(this).html( $(this).html().replace(/(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/i, "") )
	)	