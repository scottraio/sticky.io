App.Views.Templates or= {}

class App.Views.Templates.NewScreenshot extends Backbone.View

	events:
		"click a.remove" : "delete"

		
	initialize: ->
		this.unbind()
		self = this
		# the file uploader
		uploader = new qq.FileUploader
			# pass the dom node (ex. $(selector)[0] for jQuery users)
			element: $('#screenshot_to_upload')[0]
			allowedExtensions: ['png']
			debug: true
			# path to server-side upload script
			action: admin_template_screenshots_path(this.options.template_id) + ".json"
			onComplete: (id, fileName, json) ->
				console.log json

	delete: (e) ->
		_this = $(e.currentTarget)
		ajax = $.ajax
			type: "POST"
			url: _this.attr("href")
			data: {_method: "delete"}
			dataType: "json"
			success: (data, status, xhr) ->
				_this.parents(".thumb").remove()
		return false