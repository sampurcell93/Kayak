Features
========
Here are some UI features that I built into my interface.

*Filtering* - The filter bar supports a search for names or categories. For example, a search for "G" will return all businesses withj a "g" or a "G" in their name. A search for "Indian" will return all restaurants who are categorized as Indian food. Additionally, the filter buttons can eliminate food and/or hotels from the results. 

*Sorting* - The sort menu will sort all the current results into the order that you select. 


Architecture
===========
This application is written on a node.js backend, using the Yelp Search API v2. The frontend was written in CoffeeScript and Backbone.js. The implementation is fairly simple, but there are a few decisions worth discussion. First - the app utilizes both a localstorage cache and a database cache of yelp businesses in order to avoid hitting google maps geolocator and overloading our quota. Second