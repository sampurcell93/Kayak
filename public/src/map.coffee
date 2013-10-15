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
    filteredout: false
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
            window.map.map.setZoom 16
            window.map.map.setCenter self.marker.position
            self.marker.setIcon blueIcon
            new google.maps.event.trigger self.marker, 'click' 
        "deselect": ->
          if self.marker? and self.marker.getIcon() != redIcon
            self.marker.setIcon redIcon
    # Grab the businesses categories and throw em in a hash table
    # - ideally would use a trie, but aint nobody got time for that
    categorize: ->
      if !@collection then return @
      categories = @collection.categories
      self = @
      these = @get("categories")
      _.each these, (catlist) ->
        _.each catlist, (cat) ->
          cat = cat.toLowerCase()
          if categories.hasOwnProperty(cat)
            categories[cat].add self
          else 
            categories[cat] = new Businesses().add self
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
        done()
        return @
      url = @geoAddr()
      self = @
      $.ajax 
        url: url
        dataType: 'json'
        type: 'GET'
        success: (json) ->
          console.count "how are we still fetching"
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
      if window.businesses.lookingfor[@attributes.type] != false
        @marker.setMap map
      @
    bindGoogleEvents: (marker) ->
      self = @
      InfoWindow = window.map.infowindow
      google.maps.event.addListener marker, "click", ->
        InfoWindow.setContent new GMapBusiness({model: self}).render().el
        InfoWindow.open window.map.map, marker
        self.collection.list.selectItem self
      google.maps.event.addListener marker, "mouseover", ->
        self.trigger "hoverfeedback"
      google.maps.event.addListener marker, "mouseout", ->
        self.trigger "hoverfeedbackend"
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
      if @marker? and @marker.getMap() != null then @marker.setMap null
      @hidden = true
      @trigger "hide"
      @
    show: (notfiltered) ->
      if notfiltered is true and @filteredout is true then return @
      if @marker? and @marker.getMap() == null then @marker.setMap window.map.map
      @trigger "show"
      @hidden = false
      @

  Businesses = Backbone.Collection.extend
    food: []
    hotel: []
    lookingfor: { food: true, hotel: true }
    categories: {}
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
        bus.collection = self
        bus.categorize()
        # Allows O n/2ish filtering later
        self.food.push bus
        bus.set "type", "food"
      _.each response.hotels.businesses, (bus) ->
        models.push bus = new Business(bus)
        bus.collection = self
        bus.categorize()
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
      # This line has been commented out to disable infinite scroll
      # @$("ul").scroll @detectScroll
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
        success: (coll, response) ->
          if response.food.businesses.length > 0 or response.food.businesses.length > 0
            $loader.text("Load more results")
          else
            $loader.text("Sorry, there are no more nearby businesses!")
        error: ->
          $loader.text("Sorry, there are no more nearby businesses!")
        add: true
        remove: false
    render: ->
      self = @
      @$("ul").children(":not(.loader)").remove()
      _.each @collection.models, (business) ->
        self.appendChild business
      @
    appendChild: (model) ->
      if @collection.lookingfor[model.get("type")] == false then return @
      business = new BusinessItem model: model, list: @
      @$("ul").find(".loader").before business = business.render().el
      if model.filteredout != false then $(business).hide()
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
      "mouseover [data-tooltip]": (e) ->
        $t = $ e.currentTarget
        $t.data "active", true
        window.setTimeout ->
          if $t.data("active") == true
            $(".active-tooltip").removeClass "active-tooltip"
            $t.addClass "active-tooltip"
        , 700
      "mouseleave [data-tooltip]": (e) ->
        $t = $ e.currentTarget
        $t.data "active",false
        $t.removeClass "active-tooltip"
      "click .js-toggle-businesses": (e) ->
        $(".list-results").toggleClass "hidden"
        $(e.currentTarget).toggleClass "outside"
      "change [name='filterby']": (e) ->
        $t = $ e.currentTarget
        filter = $t.val()
        checked = $t.is(":checked")
        $t.parent().toggleClass "selected"
        if checked is true
          @collection.lookingfor[filter] = true
          _.each @collection[filter], (bus) ->
            bus.show true
        else
          @collection.lookingfor[filter] = false
          _.each @collection[filter], (bus) ->
            bus.hide()
      "change [name='sortby']": (e) ->
        sorts = 
          distance:(model) ->
            model.get "distance"
          rating: (model) ->
            -model.get "rating"
        $t = $ e.currentTarget
        sort = $t.val()
        $t.parent().addClass("selected").siblings(".sortby").removeClass "selected"
        @collection.comparator = sorts[sort]
        @collection.sort()
        @render()
        false
      "click .js-toggle-settings": ->
        @$(".settings").slideToggle "fast"
      "keyup .js-filter": (e) ->
        $t = $ e.currentTarget
        val = $t.val().toLowerCase().replace(" ","")
        self = @
        collection = @collection
        @collection.filter (model) ->
          if collection.lookingfor[model.get("type")] != true then return false
          # Strip the name for more hits
          title = model.get("name").replace(" ", "").replace("'","").toLowerCase()
          # check if the name matches - if it does, then the result is not a pure category result
          if title.indexOf(val) > -1 
            model.filteredout = false
            return true
          else if collection.categories[val]? and 
          collection.categories[val].indexOf(model) != -1
            model.filteredout = false
            return true
          else
            model.filteredout = true
            false
        if val == ""
          @$(".loader").show()
          collection.filter (model) ->
            model.filteredout = false
            true
        else @$(".loader").hide()
      "click .loader": "getMore"
    
  BusinessItem = Backbone.View.extend
    template: $("#business-item").html()
    tagName: 'li tabindex="1"'
    initialize: ->
      @list = @options.list
      self = @
      @listenTo @model,
        select: @select
        deselect: @deselect
        hide: @hide
        show: @show
        hoverfeedback: ->
          self.$el.addClass "hovering"
        hoverfeedbackend: ->
          self.$el.removeClass "hovering"
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
          e.preventDefault()
        # prev bindings
        else if key == 37 || key == 38 || (key == 9 && e.shiftKey == true)
          @$el.trigger("deselect").prev(":not(.hidden)").trigger "click"
          e.preventDefault()

  GMapBusiness = Backbone.View.extend
    template: $("#gmaps-view").html()
    render: ->
      @$el.html(_.template @template, @model.toJSON())
      @

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
