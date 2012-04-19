# Simple route middleware to ensure user is authenticated.
# Use this route middleware on any resource that needs to be protected.  If
# the request is authenticated (typically via a persistent login session),
# the request will proceed.  Otherwise, the user will be redirected to the
# login page.

if_authenticated = (req, res, next) ->
  next() if req.isAuthenticated()
  res.redirect('/login')

module.exports.if_authenticated = if_authenticated

