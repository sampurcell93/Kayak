This challenge took me about ten hours to complete. 

Features
========
Here are some UI features that I built into my interface.

*Filtering* - The filter bar supports a search for names or categories. For example, a search for "G" will return all businesses withj a "g" or a "G" in their name. A search for "Indian" will return all restaurants who are categorized as Indian food. Additionally, the filter buttons can eliminate food and/or hotels from the results. 

*Sorting* - The sort menu will sort all the current results into the order that you select. The currently supported options are rating and distance. 

I decided not to link the data to airports. On one hand, doing so could lead to many more cache hits if the assumed use case was correct. However, I reasoned that the tool could be much more useful than simply a tool for airport travelers to find lodging - it could be used by anyone, anywhere, to find nearby businesses. It uses the browser's geolocate module, and populates the map with nearbylocations. So it will work at an airport, or anywhere on the street.