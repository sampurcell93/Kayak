// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var WorkSpace;
    WorkSpace = Backbone.Router.extend({
      routes: {
        "business/:id": "showBusiness"
      },
      showBusiness: function(id) {
        var b;
        b = window.businesses._byId[id];
        if (b) {
          return window.businesses.selectItem(b);
        }
      }
    });
    window.app = new WorkSpace;
    return Backbone.history.start();
  });

}).call(this);
