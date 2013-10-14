### PACKAGES ###
express = require "express" 
mongo = require "mongodb"
_ = require 'underscore'
app = do express
# MONGO_URI = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL
# db = require("mongojs").connect(MONGO_URI)
yelp = require("yelp").createClient
  consumer_key: "hq2hHKOYSQFmHU_wBOosyg"
  consumer_secret: "WvnfNhJ1Umcdcnyxo8xJ9QO5tGg"
  token: "YdrbgbIcPL1zwj1JI5SD3MHOfSHgkkV2"
  token_secret: "2UEu8pkO8G24vamnDwNTdKYdbpA"

cc = (arguuments) ->
    _.each arguments, (arg) ->
        console.log arg

port = process.env.PORT || 4040
app.listen port, () ->
    cc "listening on " + port

### CONFIGURATION ###
app.configure ->
  app.use express.logger("dev")
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.errorHandler()
  app.locals.pretty = true
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + "/public")


### URI SCHEME ###
app.get "/", (req, res) ->
    res.render "index"


app.get "/search/:lat/:lng/:offset", (req, res) ->
  q = req.params
  wantfood = req.query.wantfood
  wanthotels = req.query.wanthotels
  requestobj =
      ll : q.lat + "," + q.lng
      offset: q.offset
      term: 'Food'
  json = { food: null, hotels: null}
  yelp.search requestobj, (error, food) ->
      if !err?
        json.food = food
        requestobj.term = "hotels"
        yelp.search requestobj, (error, hotels) ->
          if !err?
            json.hotels = hotels
            res.json json
          else    
            res.json json.food
      else    
          res.json err