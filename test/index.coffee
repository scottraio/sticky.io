app = require '../app'

app.models.Note.remove {}
app.models.User.remove {}
app.models.Notebook.remove {}

require './notes_test.coffee'
require './tags_test.coffee'
require './bookmarks_test.coffee'
require './notebooks_test.coffee'