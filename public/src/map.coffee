$ ->
  redIcon = "../images/redpoi.png"
  blueIcon = "../images/bluepoi.png"
  userLoc =  "../images/webloc.png"

  if !localStorage.cachedlocs?
    localStorage.cachedlocs = JSON.stringify {}
  cachedlocs = localStorage.cachedlocs

  window.cc = ->
    _.each arguments, (arg) ->
      console.log arg

  Business = Backbone.Model.extend
    hidden: false
    geoAddr: ->
      "https://maps.googleapis.com/maps/api/geocode/json?address=" + @fulladdress + "&sensor=true"
    initialize: ->
      @fulladdress = @getAddress()
      _.bindAll @, "plot", "getAddress", "geocode", "bindGoogleEvents"
      @geocode @plot
      self = @
      @on 
        "select": ->
          window.app.navigate "/business/" + self.get("id")
          if self.marker? and self.marker.getIcon() != blueIcon
            window.map.map.setZoom(16)
            window.map.map.setCenter self.marker.position
            self.marker.setIcon blueIcon
        "deselect": ->
          if self.marker? and self.marker.getIcon() != redIcon
            self.marker.setIcon redIcon
    # returns the full address for geocoding via gmaps
    getAddress: ->
      address = @attributes.location.display_address
      str = ""
      _.each address, (line)  ->
        str += "%20" + encodeURIComponent line
      str
    geocode: (done) ->
      cache = JSON.parse cachedlocs
      # Check localstorage cache for 
      if cache.hasOwnProperty @get("id")
        _.extend @attributes, cache[@get("id")]
        cc @
        done()
        return @
      url = @geoAddr()
      self = @
      $.ajax 
        url: url
        dataType: 'json'
        type: 'GET'
        success: (json) ->
          try
            geometry = json.results[0].geometry.location
            _.extend self.attributes, geometry
            cache[self.get("id")] = geometry
            localStorage.cachedlocs = JSON.stringify cache
            done()
          catch
            if _error.length
              console.log "this does not have loc data"
      @
    plot: ->
      map = window.map.map
      @marker = new google.maps.Marker
        position: new google.maps.LatLng @get("lat"), @get("lng")
        animation: google.maps.Animation.DROP
        title: @get "name"
        icon: redIcon
      @bindGoogleEvents @marker
      @marker.setMap map
      cc "plotting"
      @
    bindGoogleEvents: (marker) ->
      self = @
      google.maps.event.addListener marker, "click", ->
        self.collection.list.selectItem self
      google.maps.event.addListener marker, "mouseover", ->
        cc "moyse"
    # args: model to check next of (default to this),
    # boolean, only look for unhidden next model if true
    next: (model, active) ->
      coll = @collection
      i = coll.indexOf model || @
      next = coll.at(i + 1)
      if next?
        if active and next.hidden is true
          return @next next, true
        else return next
      else 
        null 
    # args: model to check prev of (default to this),
    # boolean, only look for unhidden next model if true
    prev: (model, active) ->
      coll = @collection
      i = coll.indexOf model || @
      prev = coll.at(i - 1)
      if prev?
        if active and prev.hidden is true
          return @prev prev, true
        else return prev
      else 
        null 
    hide: ->
      cc "hiding"
      if @marker? and @marker.getMap() != null then @marker.setMap null
      @hidden = true
      @trigger "hide"
      @
    show: ->
      cc "showinh"
      if @marker? and @marker.getMap() == null then @marker.setMap window.map.map
      @trigger "show"
      @hidden = false
      @


  Businesses = Backbone.Collection.extend
    food: []
    hotel: []
    lookingfor: { food: true, hotel: true }
    model: Business
    offset: 0
    url: -> '/search/' + @latitude + "/" + @longitude + "/" + @offset
    initialize: ->
      @sort()
      @
    parse: (response) ->  
      self = @
      models = []
      # Make each business a model
      _.each response.food.businesses, (bus) ->
        models.push bus = new Business(bus)
        # Allows O n/2ish filtering later
        self.food.push bus
        bus.set "type", "food"
      _.each response.hotels.businesses, (bus) ->
        models.push bus = new Business(bus)
        # Allows O n/2ish filtering later
        self.hotel.push bus
        bus.set "type", "hotel"
      models
    comparator: (model) ->
      model.get "distance"
    filter: (cb) ->
      _.each @models, (model) ->
        if cb(model) == false
          model.hide()
        else model.show()
      @

  BusinessList = Backbone.View.extend
    el: ".list-results"
    initialize: ->
      _.bindAll @, "detectScroll", "render", "appendChild", "selectItem"
      @collection.list = @
      self = @
      @listenTo @collection, "add", (model) ->
        self.appendChild model
      # Backbone events don't bind scroll :(
      @$("ul").scroll @detectScroll
      @
    detectScroll: (e) ->
      $t = $ e.currentTarget
      if @checkEnd $t then @getMore()
    checkEnd: (pos) ->
      pos.scrollTop() + pos.innerHeight() >= pos[0].scrollHeight - 20
    getMore: ->
      $loader = self.$(".loader")
      @collection.offset += 20
      $loader.html("<img src='../images/loader.gif' alt='loader'/>")
      @collection.fetch 
        data: 
          wantfood: @collection.lookingfor.food
          wanthotels: @collection.lookingfor.hotel
        success: ->
          $loader.text("Load more results")
        error: ->
          $loader.text("Sorry, there are no more nearby businesses!")
        add: true
        remove: false
    render: ->
      self = @
      @$el.children(":not(.loader)").remove()
      _.each @collection.models, (business) ->
        self.appendChild business
      @
    appendChild: (model) ->
      business = new BusinessItem model: model, list: @
      @$("ul").find(".loader").before business = business.render().el
      @
    # args: the model to be selected
    # unselects all items and then
    selectItem: (item) ->
      _.each @collection.models, (bus) ->
        unless bus == item
          bus.trigger "deselect"
        else item.trigger "select"
      @
    events: 
      "click .js-toggle-businesses": (e) ->
        $(".list-results").toggleClass "hidden"
        $(e.currentTarget).toggleClass "outside"
      "change [type='checkbox']": (e) ->
        $t = $ e.currentTarget
        checked = $t.is(":checked")
        filter = $t.val()
        if checked is true
          @collection.lookingfor[filter] = true
          _.each @collection[filter], (bus) ->
            bus.show()
        else
          @collection.lookingfor[filter] = false
          _.each @collection[filter], (bus) ->
            bus.hide()
      "click .js-toggle-settings": ->
        @$(".settings").slideToggle "fast"
      "keyup .js-filter": (e) ->
        $t = $ e.currentTarget
        val = $t.val().toLowerCase()
        @collection.filter (model) ->
          title = model.get("name").replace(" ", "").toLowerCase()
          title.indexOf(val) > -1
        if val == "" then @$(".loader").show()
        else @$(".loader").hide()
      "click .loader": "getMore"
    
  BusinessItem = Backbone.View.extend
    template: $("#business-item").html()
    tagName: 'li tabindex="1"'
    initialize: ->
      @list = @options.list
      @listenTo @model,
        select: @select
        deselect: @deselect
        hide: @hide
        show: @show
    render: ->
      @$el.html _.template(@template, @model.toJSON())
      @
    select: ->
      @$el.addClass("selected").focus()
      @
    deselect: ->
      @$el.removeClass("selected")
      @
    hide: ->
      @$el.hide().addClass "hidden"
    show: ->
      @$el.show().removeClass "hidden"
    events: 
      select: "select"
      deselect: "deselect"
      "click": ->
        @list.selectItem @model
        cc @model.toJSON()
      "keydown": (e) ->
        key = e.keyCode || e.which
        # next bindings
        if key == 39 || key == 40 || (key == 9 && e.shiftKey == false)
          el = @$el.trigger("deselect").next(":not(.hidden)").trigger "click" # :hidden was unresponsive...
          console.log el
          e.preventDefault()
        # prev bindings
        else if key == 37 || key == 38 || (key == 9 && e.shiftKey == true)
          @$el.trigger("deselect").prev(":not(.hidden)").trigger "click"
          e.preventDefault()

  # Make a map object, with centers and initial zoom
  Map = (@lat, @lng, @zoom) ->
    start =  new google.maps.LatLng @lat, @lng
    @infowindow = new google.maps.InfoWindow()
    @startmarker = new google.maps.Marker
      position: start
      animation: google.maps.Animation.DROP
      title: "You are here!"
      icon: userLoc
    @mapOptions = 
      center: start
      zoom: @zoom || 20
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0],@mapOptions);
    @startmarker.setMap @map
    @

  # Callback for when coordinates have been retrieved
  begin = (position) ->
    coords = position.coords
    window.map = new Map(coords.latitude, coords.longitude, 13)
    window.businesses = _.extend c = new Businesses(), coords
    businesses.map = map
    businesslist = new BusinessList collection: c
    businesses.fetch 
      data:
        wantfood: true
        wanthotels: true

  begin({coords: {latitude: 42.406705599999995, longitude: -71.1222418 }})
  # if navigator.geolocation
    # navigator.geolocation.getCurrentPosition begin
  # else
    # alert("We'll need you to use a browser that supports geolocation! Help yourself!")
