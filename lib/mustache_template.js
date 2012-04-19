(function() {
  var mustache = require('mustache'),
      template = {
    compile: function (source, options) {
      if (typeof source == 'string') {
        return function(options) {
          options.locals = options.locals || {};
          options.partials = options.partials || {};
          options.yield = options.body || {};
          return mustache.to_html(
            source, options, options.partials);
        };
      } else {
        return source;
      }
    },
    render: function (template, options) {
      template = this.compile(template, options);
      return template(options);
    }
  };
  if(typeof module !== 'undefined' && module.exports) {
    module.exports = template;
  }
}());