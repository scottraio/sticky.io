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
		re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g
		$(this).html( $(this).html().replace(re, '<a href="$1">$1</a>') )
	)

$.fn.autotag = () ->
	return this.each( () ->
		re = /( [#]+[A-Za-z0-9-_]+)/g
		$(this).html( $(this).html().replace(re, '<span class="tag">$1</span>') )
	)
