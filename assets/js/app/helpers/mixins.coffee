#_.extend Backbone.Collection.prototype, Backbone.Events, 
#	all: (fragment) ->
#		this.url = fragment
#		this.fetch()
#		return this

$.fn.hasAncestor = (a) ->
	return this.filter () ->
		return !!$(this).closest(a).length

if Zepto is undefined
	$[ "ui" ][ "autocomplete" ].prototype["_renderItem"] = ( ul, item) ->
		return $( "<li></li>" ) 
		  .data( "item.autocomplete", item )
		  .append( $( "<a></a>" ).html( item.label ) )
		  .appendTo( ul );

String.prototype.contains = (it) -> return this.indexOf(it) != -1
