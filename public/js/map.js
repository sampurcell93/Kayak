// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var Map, User, begin, userdata;
    userdata = localStorage.userdata;
    window.cc = function() {
      return _.each(arguments, function(arg) {
        return console.log(arg);
      });
    };
    User = Backbone.Model.extend({
      url: '/search',
      initialize: function() {
        return _.each(userdata, function(datum) {
          return cc(datum);
        });
      }
    });
    begin = function(position) {
      var coords, lat, lng;
      coords = position.coords;
      lat = coords.latitude;
      lng = coords.longitude;
      cc(lat);
      cc(lng);
      window.map = new Map(lat, lng, 17);
      return window.user = new User({
        lat: lat,
        lng: lng
      });
    };
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(begin);
    } else {
      alert("We'll need you to use a browser that supports geolocation! Help yourself!");
    }
    return Map = function(lat, lng, zoom) {
      var start;
      this.lat = lat;
      this.lng = lng;
      this.zoom = zoom;
      start = new google.maps.LatLng(this.lat, this.lng);
      this.infowindow = new google.maps.InfoWindow();
      this.startmarker = new google.maps.Marker({
        position: start,
        animation: google.maps.Animation.DROP,
        title: "You are here!"
      });
      this.mapOptions = {
        center: start,
        zoom: this.zoom || 20,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      this.map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0], this.mapOptions);
      this.startmarker.setMap(this.map);
      return this;
    };
  });

}).call(this);
