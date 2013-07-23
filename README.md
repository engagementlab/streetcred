StreetCred
====

Introduction
------------

StreetCred is a civic reputation API.  It accepts incoming POST requests and calculates the user's awards based on pre-defined campaign criteria. Based on what criteria have been fulfilled, messages will be returned (as json) so that status updates can be displayed in the originating app.

Installation
-------------

StreetCred was built on a Heroku server and expects certain Heroku add-ons:

- MongoHQ - database
- CloudMailIn - for incoming email
- SendGrid - for outbound email

It also expects an associated AWS S3 account (for badge image uploads), which is linked with the following config variables:

- AWS_ACCESS_KEY_ID: 'your ID'
- AWS_BUCKET: 'your bucket'
- AWS_SECRET_ACCESS_KEY: 'your secret'

Technical
-------------

Currently, there are five API callback URLs:

https://streetcred.herokuapp.com/api/actions/ (generic)
https://streetcred.herokuapp.com/api/actions/citizens_connect
https://streetcred.herokuapp.com/api/actions/email
https://streetcred.herokuapp.com/api/actions/foursquare
https://streetcred.herokuapp.com/api/actions/street_bump

New adapters can be written in api/actions_controller.rb.  A matching route must also be added to config/routes.rb

Test the API using curl:

curl -X POST -H "Content-Type: application/json" -d '{"api_key":"apikeyhere", "action_type":"Patch Report","email":"youremail@gmail.com","latitude":"42.359885","longitude":"-71.057983"}' http://streetcred.us/api/actions.json


Schema
-------------

Actions consist of the following attributes:
  
- :user_id, type: Integer
- :channel_id, type: Integer
- :action_type_id, type: Integer
- :campaign_id, type: Integer
- :api_key, type: String
- :record_id, type: String
- :case_id, type: String
- :action_type, type: String
- :description, type: String
- :shared, type: Boolean
- :location, type: String
- :latitude, type: BigDecimal
- :longitude, type: BigDecimal
- :address, type: String
- :city, type: String
- :zipcode, type: String
- :state, type: String
- :url, type: String
- :photo_url, type: String
- :timestamp, type: String