#
# remove html from the a string
Handlebars.registerHelper 'htmlsafe', (string) ->
	return new Handlebars.SafeString(string.replace(/(<[^>]+) style=".*?"/g, '$1'))

#
# show the date/time in words (ago)
Handlebars.registerHelper 'time_in_words', (date) ->
	return new Handlebars.SafeString($.timeago(date))

#
# easy date formatter
Handlebars.registerHelper 'format_date', (date) ->
	date = new Date(date)
	return new Handlebars.SafeString(date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear())

#
# subnote count
Handlebars.registerHelper 'subnote_count', () ->
	if @_notes.length > 0
		return new Handlebars.SafeString("<span class=\"subnote-count\">#{@_notes.length} notes</span>") 
	else
		return new Handlebars.SafeString("") 

#
# is this note in the first position
Handlebars.registerHelper 'is_pole_position', () ->
	if @_notes.length > 0
		return "pole-position"		

#
# show the taskable checkbox
Handlebars.registerHelper 'if_taskable_then_show_checkbox', () ->
	if @message && @message.indexOf('#todo') > 0
		return "<input type=\"checkbox\" class=\"task-completed\" #{ 'checked=\"true\"' if @completed } />"

#
# show the notebook labels
Handlebars.registerHelper 'notebook_labels', () ->
	labels = ""
	notebooks = _.uniq @groups
	for notebook in notebooks
		color = $("li[data-name=#{notebook}]").attr('data-color')
		labels += "<span class=\"label #{color}\">@#{notebook}</span>"
	return new Handlebars.SafeString(labels)

#
# css classes for a sticky card
Handlebars.registerHelper 'card_css', () ->
	has_subnotes = true if @_notes.length > 0
	css = "sticky card"
	css += " stacked" if has_subnotes
	return css

#
# is this note draggable? if so set the html 5 attribute
Handlebars.registerHelper 'draggable', () ->
	return "draggable=true" if @_notes.length <= 0 or (@parent && @parent.length > 0)

#
# get rid of stray links 
Handlebars.registerHelper 'remove_stray_links', () ->
	if @_domains && @_domains.length > 0
		return "remove-stray-links"

Handlebars.registerHelper 'domain', () ->
	if @_domains && @_domains.length > 0
		return @url.toLocation().hostname if @url





	