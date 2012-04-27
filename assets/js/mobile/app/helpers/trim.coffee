window.trim = (val) ->
  if String::trim? then val.trim() else val.replace /^\s+|\s+$/g, ""