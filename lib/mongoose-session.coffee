SessionMongoose = require 'session-mongoose'

mongooseSessionStore = new SessionMongoose
	url: "mongodb://localhost/pine-io-development",
	interval: 120000 # expiration check worker run interval in millisec (default: 60000)

module.exports = mongooseSessionStore