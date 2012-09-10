# copy from lib/regex.coffee
window.match = 
	tag 		: /(^|\s)#([^\s]+)/g
	group 	: /(^|\s)@([^\s]+)/g
	link 		: /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g

class App.Main extends Backbone.View
	
	events:
		"click #delete-note .danger" 	: "delete_note"
		"click a.navigate" 						: "link_to_fragment"
		"click a.order"								: "link_to_sort"
		"click a.push" 								: "link_to_push"
		
	initialize: ->
		$('.dropdown-toggle').dropdown()

		today					= new Date()
		threedaysago 	= new Date(new Date().setDate(today.getDate() - 3))

		# date picker
		$('.date-picker').DatePicker
			format: '/m/d/Y',
			flat: true,
			extraHeight: 0,
			mode: 'range',
			date: [threedaysago, today],
			current: new Date(),
			calendars: 1,
			starts: 1
			onChange: (formated, dates) ->
				d1 		= new Date(dates[0])
				d2		= new Date(dates[1])
				start = d1.toJSON()
				end 	= d2.toJSON()
				navigate "/notes?start=#{start}&end=#{end}"

		new App.Views.Notes.New(el: $('#new-sticky-header'))

	delete_note: (e) ->
		note_id = $('#delete-note').attr('data-id')
		note = new App.Models.Note(id: note_id)
		note.destroy
			success: (model, res) ->
				# clear the html from the expanded view
				$("#expanded-view").html('')
				# remove the sticky from the inbox
				$("li.sticky[data-id=#{note_id}]").remove()
				$('#delete-note').modal('hide')
		return false

	link_to_sort: (e) ->
		direction = $(e.currentTarget).attr('data-direction')
		search = document.location.search.replace(/(&|order=)[^\&]+/, '')
		search = search + "&order=#{direction}"
		navigate document.location.pathname + search
		return false
	
	link_to_fragment: (e) ->
		navigate $(e.currentTarget).attr("href")
		return false

	link_to_push: (e) ->
		push_url $(e.currentTarget).attr("href")
		return false
	
