#
# Realtime "routes"

exports.bind = (current_user_id, socket) ->
	
	#
	# Stack
	socket.on 'notes:stack', (data) ->
		app.models.User.findOne {_id: current_user_id}, (err, user) ->
			
			options = { 
				child_id 	: data.child_id
				parent_id : data.parent_id
			}

			app.models.Note.stack user, options, (child, parent) ->
				console.log 'stacked' if app.env is 'development'
				return child

	#
	# Restack
	socket.on 'notes:restack', (data) ->
		app.models.User.findOne {_id: current_user_id}, (err, user) ->
			
			options = {
				child_id 	: data.child_id
				old_id 		: data.old_id
				parent_id : data.parent_id
			}

			app.models.Note.restack user, options, (child, old_parent, parent) ->
				console.log 'restacked' if app.env is 'development'
				return child

	#
	# Unstack
	socket.on 'notes:unstack', (data) ->
		console.log data
		app.models.User.findOne {_id: current_user_id}, (err, user) ->

			options = {
				child_id 	: data.child_id
				parent_id : data.parent_id
			}

			app.models.Note.unstack user, options, (child, parent) ->
				console.log 'unstacked' if app.env is 'development'
				user.broadcast('ui:cleanup:empty_stack', parent) if parent._notes.length is 0
				user.broadcast('note:add', child)
