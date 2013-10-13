### PACKAGES ###
express = require "express" 
mongo = require "mongodb"
_ = require 'underscore'
app = do express
MONGO_URI = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "builder"
db = require("mongojs").connect(MONGO_URI)
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


app.get "/search", (req, res) ->
    requestobj =
        ll : req.query.lat + "," + req.query.lng
        term  : req.query.type
    cc requestobj
    yelp.search {location: 'Montreal', term: 'food'}, (error, data) ->
        if !err?
            cc data.businesses.length
            res.json data
        else    
            res.json err