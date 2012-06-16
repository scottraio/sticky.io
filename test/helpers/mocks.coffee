exports.user = {
	email   	 : 'test@pine.io'
	name 		 : 'Scott Raio'
	password	 : 'pinerocks'
}

exports.note = {
	message 	: 'pick up milk #todo'
	created_at	: new Date()
	_user 		: '4fa066c415b5565702000008'
}

exports.group = {
	name 		: 'apt14'
	created_at	: new Date()
	_users 		: ['4fa066c415b5565702000008', '4fa066c415b5565702000008']
	_moderators : ['4fa066c415b5565702000008', '4fa066c415b5565702000008']
}