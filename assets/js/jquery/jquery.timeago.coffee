(($) ->
  refresh = ->
    data = prepareData(this)
    $(this).text inWords(data.datetime)  unless isNaN(data.datetime)
    this
  prepareData = (element) ->
    element = $(element)
    unless element.data("timeago")
      element.data "timeago", datetime: $t.datetime(element)
      text = $.trim(element.text())
      element.attr "title", text  if text.length > 0
    element.data "timeago"
  inWords = (date) ->
    $t.inWords distance(date)
  distance = (date) ->
    new Date().getTime() - date.getTime()
  $.timeago = (timestamp) ->
    if timestamp instanceof Date
      inWords timestamp
    else if typeof timestamp == "string"
      inWords $.timeago.parse(timestamp)
    else
      inWords $.timeago.datetime(timestamp)
  
  $t = $.timeago
  $.extend $.timeago, 
    settings: 
      refreshMillis: 60000
      allowFuture: false
      strings: 
        prefixAgo: null
        prefixFromNow: null
        suffixAgo: "ago"
        suffixFromNow: "from now"
        seconds: "less than a minute"
        minute: "about a minute"
        minutes: "%d minutes"
        hour: "about an hour"
        hours: "about %d hours"
        day: "a day"
        days: "%d days"
        month: "about a month"
        months: "%d months"
        year: "about a year"
        years: "%d years"
        numbers: []
    
    inWords: (distanceMillis) ->
      substitute = (stringOrFunction, number) ->
        string = (if $.isFunction(stringOrFunction) then stringOrFunction(number, distanceMillis) else stringOrFunction)
        value = ($l.numbers and $l.numbers[number]) or number
        string.replace /%d/i, value
      $l = @settings.strings
      prefix = $l.prefixAgo
      suffix = $l.suffixAgo
      if @settings.allowFuture
        if distanceMillis < 0
          prefix = $l.prefixFromNow
          suffix = $l.suffixFromNow
        distanceMillis = Math.abs(distanceMillis)
      seconds = distanceMillis / 1000
      minutes = seconds / 60
      hours = minutes / 60
      days = hours / 24
      years = days / 365
      words = seconds < 45 and substitute($l.seconds, Math.round(seconds)) or seconds < 90 and substitute($l.minute, 1) or minutes < 45 and substitute($l.minutes, Math.round(minutes)) or minutes < 90 and substitute($l.hour, 1) or hours < 24 and substitute($l.hours, Math.round(hours)) or hours < 48 and substitute($l.day, 1) or days < 30 and substitute($l.days, Math.floor(days)) or days < 60 and substitute($l.month, 1) or days < 365 and substitute($l.months, Math.floor(days / 30)) or years < 2 and substitute($l.year, 1) or substitute($l.years, Math.floor(years))
      $.trim [ prefix, words, suffix ].join(" ")
    
    parse: (iso8601) ->
      s = $.trim(iso8601)
      s = s.replace(/\.\d\d\d+/, "")
      s = s.replace(/-/, "/").replace(/-/, "/")
      s = s.replace(/T/, " ").replace(/Z/, " UTC")
      s = s.replace(/([\+\-]\d\d)\:?(\d\d)/, " $1$2")
      new Date(s)
    
    datetime: (elem) ->
      isTime = $(elem).get(0).tagName.toLowerCase() == "time"
      iso8601 = (if isTime then $(elem).attr("datetime") else $(elem).attr("title"))
      $t.parse iso8601
  
  $.fn.timeago = ->
    self = this
    self.each refresh
    $s = $t.settings
    if $s.refreshMillis > 0
      setInterval (->
        self.each refresh
      ), $s.refreshMillis
    self
  
  document.createElement "abbr"
  document.createElement "time"
) $