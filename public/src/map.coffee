$ ->

  userdata = localStorage.userdata

  window.cc = ->
    _.each arguments, (arg) ->
        console.log arg

  User = Backbone.Model.extend
    url: '/search'
    initialize: ->
      _.each userdata, (datum) ->
        cc datum

  begin = (position) ->
    coords = position.coords
    lat = coords.latitude
    lng = coords.longitude
    cc lat
    cc lng
    window.map = new Map(lat, lng, 17)
    window.user = new User {lat: lat, lng: lng}

  if navigator.geolocation
    navigator.geolocation.getCurrentPosition begin
  else
    alert("We'll need you to use a browser that supports geolocation! Help yourself!")

  Map = (@lat, @lng, @zoom) ->
    start =  new google.maps.LatLng @lat, @lng
    @infowindow = new google.maps.InfoWindow()
    @startmarker = new google.maps.Marker(
        position: start
        animation: google.maps.Animation.DROP
        title: "You are here!"
    )
    @mapOptions = 
      center: start
      zoom: @zoom || 20
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0],@mapOptions);
    @startmarker.setMap @map
    @
