App.Views.Members or= {}

class App.Views.Groups.Members extends Backbone.View

	events:
		'click .add-member'	: 'clone'
		'click .rem-member'	: 'remove'	
	
	initialize: ->

	clone: (e) ->
		new_member = $(e.currentTarget).parent('.member').clone()
		$('input', new_member).val("")
		$(@el).append new_member
		return false

	remove: (e) ->
		new_member = $(e.currentTarget).parent('.member').remove()
		return false
