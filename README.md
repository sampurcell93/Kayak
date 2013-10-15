Find Somewhere
==============
This challenge took me about ten hours to complete. The live app can be found at http://kayakbaby.herokuapp.com .

What it does
------------
Here are some UI features that I built into my interface.

*Filtering* - The filter bar supports a search for names or categories. For example, a search for "G" will return all businesses withj a "g" or a "G" in their name. A search for "Indian" will return all restaurants who are categorized as Indian food. Additionally, the filter buttons can eliminate food and/or hotels from the results. 

*Sorting* - The sort menu will sort all the current results into the order that you select. The currently supported options are rating and distance. 

*Mobile friendly* - each business can be viewed in two ways. The first is as a popup on the map. I noticed that this posed a significant challenge to mobile users, because the maps interface is not mobile friendly, and the list gets in the way (tested on iphome 4). I added an option for users to pop out the data into a responsive modal, which overlays the entire page. This solves the problem of an inaccessible map.

*Routes* - The app uses a basic routing scheme in order to allow for people to link to pages.

I decided not to link the data to airports. On one hand, doing so could lead to many more cache hits if the assumed use case was correct. However, I reasoned that the tool could be used by people other than travelers - it could be used by anyone, anywhere, to find nearby businesses. It uses the browser's geolocate module, and populates the map with nearby locations. It will work anywhere that yelp supports.

### Architecture
The application is built on Backbone.js. See public/src for the modules.