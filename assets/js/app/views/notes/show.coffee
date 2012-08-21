App.Views.Notes or= {}

class App.Views.Notes.Show extends Backbone.View

	events:
		'click .delete' 	: 'delete'
		'keyup textarea' : 'autosave'

	initialize: ->
		@note 			= new App.Models.Note(id: @options.id)
		@note.url 	= "/notes/#{@options.id}/expanded.json"

	render: () ->
		self = @
		@note.fetch 
			success: (err, notesJSON) -> 
				notes = []
				for note in notesJSON
					if note._id is self.options.id
						parent = note 
					else
						notes.push note
			
				$(self.el).html ich.expanded_note
					parent_note : parent
					notes 			: notes
					stacked_at_in_words	: () -> this.stacked_at && $.timeago(this.stacked_at)


				$('textarea', self.el).autosize()

	autosave: (e) ->
		self 	= @	
		@note = new App.Models.Note(id: @options.id)
		idle 	= 0
		clearTimeout(@timer)

		@timer = setTimeout((->
			save self.note, { message : $('textarea', self.el).val() }, {
				success: (data, res) ->
					$('#save-notice').html('Saved')
					self.timer = setTimeout((->						
						$('#save-notice').html('')
					), 3000)
				error: (data, res) ->
					console.log 'error'
			}
		), 3000)



	delete: (e) ->
			self = @
			note_id = $(e.currentTarget).attr('data-id')
			note = new App.Models.Note(id: note_id)
			note.destroy
				success: (model, res) ->
					# clear the html from the expanded view
					$(self.el).html('')
					# remove the sticky from the inbox
					$("li.sticky[data-id=#{note_id}]").remove()
			return false

