App.Views.Records or= {}

class App.Views.Records.Edit extends Backbone.View
	
	events: _.extend(
		click_or_tap {
			"input.related" : "related_search"
		}, {
			"change select.country_select" 	: "populate_states"
		}
	)
	
	initialize: ->
		#udo 			= new App.Views.Records.UserDefinedOrder( _.extend(this.options, action: "edit" ) ) if Modernizr.localstorage
		#highlight = new App.Views.Fields.Highlight(el: $("fieldset"))
		#$("fieldset input[type*=text]:first").tipsy({trigger: "focus"})
		$("fieldset input[type*=text]").first().focus()
		
	# show states from the selected country
	populate_states: (e) ->
		$.get "/ui/states_for_country/" + $(e.currentTarget).val(), (data) ->
			$("#doc_" + $(e.currentTarget).attr("rel") + "_state").html(data)

	related_search: (e) ->
		e.stopPropagation()
		new App.Views.Forms.RelatedSearch(input: $(e.currentTarget), el: @el)	


