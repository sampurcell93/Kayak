// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var Business, BusinessItem, BusinessList, Businesses, GMapBusiness, Map, begin, blueIcon, cachedlocs, redIcon, userLoc;
    redIcon = "../images/redpoi.png";
    blueIcon = "../images/bluepoi.png";
    userLoc = "../images/webloc.png";
    if (localStorage.cachedlocs == null) {
      localStorage.cachedlocs = JSON.stringify({});
    }
    cachedlocs = localStorage.cachedlocs;
    window.cc = function() {
      return _.each(arguments, function(arg) {
        return console.log(arg);
      });
    };
    Business = Backbone.Model.extend({
      filteredout: false,
      hidden: false,
      geoAddr: function() {
        return "https://maps.googleapis.com/maps/api/geocode/json?address=" + this.fulladdress + "&sensor=true";
      },
      initialize: function() {
        var self;
        this.fulladdress = this.getAddress();
        _.bindAll(this, "plot", "getAddress", "geocode", "bindGoogleEvents");
        this.geocode(this.plot);
        self = this;
        return this.on({
          "select": function() {
            window.app.navigate("/business/" + self.get("id"));
            if ((self.marker != null) && self.marker.getIcon() !== blueIcon) {
              window.map.map.setZoom(16);
              window.map.map.setCenter(self.marker.position);
              self.marker.setIcon(blueIcon);
              return new google.maps.event.trigger(self.marker, 'click');
            }
          },
          "deselect": function() {
            if ((self.marker != null) && self.marker.getIcon() !== redIcon) {
              return self.marker.setIcon(redIcon);
            }
          }
        });
      },
      categorize: function() {
        var categories, self, these;
        if (!this.collection) {
          return this;
        }
        categories = this.collection.categories;
        self = this;
        these = this.get("categories");
        return _.each(these, function(catlist) {
          return _.each(catlist, function(cat) {
            cat = cat.toLowerCase();
            if (categories.hasOwnProperty(cat)) {
              return categories[cat].add(self);
            } else {
              return categories[cat] = new Businesses().add(self);
            }
          });
        });
      },
      getAddress: function() {
        var address, str;
        address = this.attributes.location.display_address;
        str = "";
        _.each(address, function(line) {
          return str += "%20" + encodeURIComponent(line);
        });
        return str;
      },
      geocode: function(done) {
        var cache, self, url;
        cache = JSON.parse(cachedlocs);
        if (cache.hasOwnProperty(this.get("id"))) {
          _.extend(this.attributes, cache[this.get("id")]);
          done();
          return this;
        }
        url = this.geoAddr();
        self = this;
        $.ajax({
          url: url,
          dataType: 'json',
          type: 'GET',
          success: function(json) {
            var geometry;
            console.count("how are we still fetching");
            try {
              geometry = json.results[0].geometry.location;
              _.extend(self.attributes, geometry);
              cache[self.get("id")] = geometry;
              localStorage.cachedlocs = JSON.stringify(cache);
              return done();
            } catch (_error) {
              if (_error.length) {
                return console.log("this does not have loc data");
              }
            }
          }
        });
        return this;
      },
      plot: function() {
        var map;
        map = window.map.map;
        this.marker = new google.maps.Marker({
          position: new google.maps.LatLng(this.get("lat"), this.get("lng")),
          animation: google.maps.Animation.DROP,
          title: this.get("name"),
          icon: redIcon
        });
        this.bindGoogleEvents(this.marker);
        if (window.businesses.lookingfor[this.attributes.type] !== false) {
          this.marker.setMap(map);
        }
        return this;
      },
      bindGoogleEvents: function(marker) {
        var InfoWindow, self;
        self = this;
        InfoWindow = window.map.infowindow;
        google.maps.event.addListener(marker, "click", function() {
          InfoWindow.setContent(new GMapBusiness({
            model: self
          }).render().el);
          InfoWindow.open(window.map.map, marker);
          return self.collection.list.selectItem(self);
        });
        google.maps.event.addListener(marker, "mouseover", function() {
          return self.trigger("hoverfeedback");
        });
        return google.maps.event.addListener(marker, "mouseout", function() {
          return self.trigger("hoverfeedbackend");
        });
      },
      next: function(model, active) {
        var coll, i, next;
        coll = this.collection;
        i = coll.indexOf(model || this);
        next = coll.at(i + 1);
        if (next != null) {
          if (active && next.hidden === true) {
            return this.next(next, true);
          } else {
            return next;
          }
        } else {
          return null;
        }
      },
      prev: function(model, active) {
        var coll, i, prev;
        coll = this.collection;
        i = coll.indexOf(model || this);
        prev = coll.at(i - 1);
        if (prev != null) {
          if (active && prev.hidden === true) {
            return this.prev(prev, true);
          } else {
            return prev;
          }
        } else {
          return null;
        }
      },
      hide: function() {
        if ((this.marker != null) && this.marker.getMap() !== null) {
          this.marker.setMap(null);
        }
        this.hidden = true;
        this.trigger("hide");
        return this;
      },
      show: function(notfiltered) {
        if (notfiltered === true && this.filteredout === true) {
          return this;
        }
        if ((this.marker != null) && this.marker.getMap() === null) {
          this.marker.setMap(window.map.map);
        }
        this.trigger("show");
        this.hidden = false;
        return this;
      }
    });
    Businesses = Backbone.Collection.extend({
      food: [],
      hotel: [],
      lookingfor: {
        food: true,
        hotel: true
      },
      categories: {},
      model: Business,
      offset: 0,
      url: function() {
        return '/search/' + this.latitude + "/" + this.longitude + "/" + this.offset;
      },
      initialize: function() {
        this.sort();
        return this;
      },
      parse: function(response) {
        var models, self;
        self = this;
        models = [];
        _.each(response.food.businesses, function(bus) {
          models.push(bus = new Business(bus));
          bus.collection = self;
          bus.categorize();
          self.food.push(bus);
          return bus.set("type", "food");
        });
        _.each(response.hotels.businesses, function(bus) {
          models.push(bus = new Business(bus));
          bus.collection = self;
          bus.categorize();
          self.hotel.push(bus);
          return bus.set("type", "hotel");
        });
        return models;
      },
      comparator: function(model) {
        return model.get("distance");
      },
      filter: function(cb) {
        _.each(this.models, function(model) {
          if (cb(model) === false) {
            return model.hide();
          } else {
            return model.show();
          }
        });
        return this;
      }
    });
    BusinessList = Backbone.View.extend({
      el: ".list-results",
      initialize: function() {
        var self;
        _.bindAll(this, "detectScroll", "render", "appendChild", "selectItem");
        this.collection.list = this;
        self = this;
        this.listenTo(this.collection, "add", function(model) {
          return self.appendChild(model);
        });
        return this;
      },
      detectScroll: function(e) {
        var $t;
        $t = $(e.currentTarget);
        if (this.checkEnd($t)) {
          return this.getMore();
        }
      },
      checkEnd: function(pos) {
        return pos.scrollTop() + pos.innerHeight() >= pos[0].scrollHeight - 20;
      },
      getMore: function() {
        var $loader;
        $loader = self.$(".loader");
        this.collection.offset += 20;
        $loader.html("<img src='../images/loader.gif' alt='loader'/>");
        return this.collection.fetch({
          data: {
            wantfood: this.collection.lookingfor.food,
            wanthotels: this.collection.lookingfor.hotel
          },
          success: function() {
            return $loader.text("Load more results");
          },
          error: function() {
            return $loader.text("Sorry, there are no more nearby businesses!");
          },
          add: true,
          remove: false
        });
      },
      render: function() {
        var self;
        self = this;
        this.$el.children(":not(.loader)").remove();
        _.each(this.collection.models, function(business) {
          return self.appendChild(business);
        });
        return this;
      },
      appendChild: function(model) {
        var business;
        if (this.collection.lookingfor[model.get("type")] === false) {
          return this;
        }
        business = new BusinessItem({
          model: model,
          list: this
        });
        this.$("ul").find(".loader").before(business = business.render().el);
        return this;
      },
      selectItem: function(item) {
        _.each(this.collection.models, function(bus) {
          if (bus !== item) {
            return bus.trigger("deselect");
          } else {
            return item.trigger("select");
          }
        });
        return this;
      },
      events: {
        "click .js-toggle-businesses": function(e) {
          $(".list-results").toggleClass("hidden");
          return $(e.currentTarget).toggleClass("outside");
        },
        "change [type='checkbox']": function(e) {
          var $t, checked, filter;
          $t = $(e.currentTarget);
          checked = $t.is(":checked");
          filter = $t.val();
          $t.parent().toggleClass("selected");
          if (checked === true) {
            this.collection.lookingfor[filter] = true;
            return _.each(this.collection[filter], function(bus) {
              return bus.show(true);
            });
          } else {
            this.collection.lookingfor[filter] = false;
            return _.each(this.collection[filter], function(bus) {
              return bus.hide();
            });
          }
        },
        "click .js-toggle-settings": function() {
          return this.$(".settings").slideToggle("fast");
        },
        "keyup .js-filter": function(e) {
          var $t, collection, self, val;
          $t = $(e.currentTarget);
          val = $t.val().toLowerCase().replace(" ", "");
          self = this;
          collection = this.collection;
          this.collection.filter(function(model) {
            var title;
            if (collection.lookingfor[model.get("type")] !== true) {
              return false;
            }
            title = model.get("name").replace(" ", "").replace("'", "").toLowerCase();
            if (title.indexOf(val) > -1) {
              model.filteredout = false;
              return true;
            } else if ((collection.categories[val] != null) && collection.categories[val].indexOf(model) !== -1) {
              model.filteredout = false;
              return true;
            } else {
              model.filteredout = true;
              return false;
            }
          });
          if (val === "") {
            return this.$(".loader").show();
          } else {
            return this.$(".loader").hide();
          }
        },
        "click .loader": "getMore"
      }
    });
    BusinessItem = Backbone.View.extend({
      template: $("#business-item").html(),
      tagName: 'li tabindex="1"',
      initialize: function() {
        var self;
        this.list = this.options.list;
        self = this;
        return this.listenTo(this.model, {
          select: this.select,
          deselect: this.deselect,
          hide: this.hide,
          show: this.show,
          hoverfeedback: function() {
            return self.$el.addClass("hovering");
          },
          hoverfeedbackend: function() {
            return self.$el.removeClass("hovering");
          }
        });
      },
      render: function() {
        this.$el.html(_.template(this.template, this.model.toJSON()));
        return this;
      },
      select: function() {
        this.$el.addClass("selected").focus();
        return this;
      },
      deselect: function() {
        this.$el.removeClass("selected");
        return this;
      },
      hide: function() {
        return this.$el.hide().addClass("hidden");
      },
      show: function() {
        return this.$el.show().removeClass("hidden");
      },
      events: {
        select: "select",
        deselect: "deselect",
        "click": function() {
          this.list.selectItem(this.model);
          return cc(this.model.toJSON());
        },
        "keydown": function(e) {
          var el, key;
          key = e.keyCode || e.which;
          if (key === 39 || key === 40 || (key === 9 && e.shiftKey === false)) {
            el = this.$el.trigger("deselect").next(":not(.hidden)").trigger("click");
            return e.preventDefault();
          } else if (key === 37 || key === 38 || (key === 9 && e.shiftKey === true)) {
            this.$el.trigger("deselect").prev(":not(.hidden)").trigger("click");
            return e.preventDefault();
          }
        }
      }
    });
    GMapBusiness = Backbone.View.extend({
      template: $("#gmaps-view").html(),
      render: function() {
        this.$el.html(_.template(this.template, this.model.toJSON()));
        return this;
      }
    });
    Map = function(lat, lng, zoom) {
      var start;
      this.lat = lat;
      this.lng = lng;
      this.zoom = zoom;
      start = new google.maps.LatLng(this.lat, this.lng);
      this.infowindow = new google.maps.InfoWindow();
      this.startmarker = new google.maps.Marker({
        position: start,
        animation: google.maps.Animation.DROP,
        title: "You are here!",
        icon: userLoc
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
    begin = function(position) {
      var businesslist, c, coords;
      coords = position.coords;
      window.map = new Map(coords.latitude, coords.longitude, 13);
      window.businesses = _.extend(c = new Businesses(), coords);
      businesses.map = map;
      businesslist = new BusinessList({
        collection: c
      });
      return businesses.fetch({
        data: {
          wantfood: true,
          wanthotels: true
        }
      });
    };
    return begin({
      coords: {
        latitude: 42.406705599999995,
        longitude: -71.1222418
      }
    });
  });

}).call(this);
