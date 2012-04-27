class Mob.Views.Main extends Backbone.View
	
	events: 
		"touchend form .submit" : "link_to_submit"

	link_to_submit: (e) ->
		# tag a link or button with the id="submit" and rel="#some_target"
		# to have that objects parent form be submitted in ajax. oh yea, it will
		# also disable the button or link to prevent double submissions
		self 	= $(e.currentTarget)
		form 	= self.closest("form")

		$.post $(form).attr("action"), $(form).serializeForm(), (data) ->
			console.log data

		return false