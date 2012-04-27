App.Views.Records or= {}

class App.Views.Records.RelatedSearch extends Backbone.View


	initialize: () ->
		self = @
		@el.autocomplete
			minLength: 2
			source: (request,response) ->
				$.ajax
					url: "/reports/#{self.el.attr('data-report-id')}",
					dataType: "json",
					data:
						keyword: request.term
					success: (data) -> 
						response $.map( data, (item) ->
							return {
								label: self.autocomplete_highlight(item.name, request.term) + self.autocomplete_pretty_values(item, request.term),
								value: item.name,
								record_id: item.id,
								name: item.name
							}
						)
			select: (event, ui) ->
				self.el.next("input.related_record_id").val(ui.item.record_id)
				self.el.parents("span.field").append $("<input type='hidden' name='related_ids[]' value='#{ui.item.record_id}' />")

				
	autocomplete_highlight: (string, text) -> 
		unless string is null
			match = new RegExp("("+$.ui.autocomplete.escapeRegex(text)+")", "gi")
			return string.replace(match,'<strong>$1</strong>')
				  
	autocomplete_pretty_values: (item, text) ->
		self 	= this
		match 	= ""
			
		for entry in item.values
			match = self.autocomplete_find_match_in_value(entry, entry.value, text)
			return (" - " + match) unless match is false or match is undefined
			
		return ""
			
	autocomplete_find_match_in_value: (entry, val, text) ->
		self = this	
		
		switch typeof(val)
			when 'object'
				for subfield_name, subfield_value of val
					match = self.autocomplete_find_match_in_value(entry, (subfield_value+""), text)
					return match unless match is false
			when 'string'
				return entry.field_name + ": " + self.autocomplete_highlight(val,text) if val.contains(text)
			else
				return false