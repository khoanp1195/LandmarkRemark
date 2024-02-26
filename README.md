Requirements: Create an app that allows users to store location-based notes on a map.
Technology: iOS – Swift
Data storage: Realm
Solution:
•	Initially, I chose the readily available Swift library MKMapView to display the map image.

•	Next, I implemented a long press gesture to display a popup for the user to enter (Address, Descriptions). 

•	Upon user's save action, the data is stored in the database and a marker is displayed on the map based on the Latitude and Longitude values.

•	Clicking on a marker will display its information.

•	Every time the user accesses the application, the data is reloaded from the database.

•	Users can review a list of all the markers they have created.

•	 Users can delete markers from the list.

•	Users can search for markers using the search bar.

•	When a user clicks on a search result, the application will focus on the corresponding location on the map.

Limitations:
The application currently has some limitations, including:
Data:
•	Storage: The data used is still stored locally, not uploaded to the server.
•	Functionality: Data can currently only be viewed and deleted, and there is no editing function.
Information: The information provided for the markers is still limited.











