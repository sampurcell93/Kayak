// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var Underscore, types;
    types = [
      {
        value: "Restaurants",
        tokens: ["Food", "Restaurants"]
      }, {
        value: "Hotels",
        tokens: ["Hotel", "Lodging", "bed", "sleep"]
      }, {
        value: "Motels",
        tokens: ["motel", "lodging", "bed", "sleep"]
      }, {
        value: "Lodging",
        tokens: ["lodging", "sleep", "bed"]
      }
    ];
    Underscore = {
      compile: function(template) {
        var compiled;
        compiled = _.template(template);
        return {
          render: function(context) {
            return compiled(context);
          }
        };
      }
    };
    return $(".js-search-types").typeahead({
      local: types,
      limit: 10000,
      engine: Underscore,
      template: $("#typeahead-item")
    });
  });

}).call(this);
