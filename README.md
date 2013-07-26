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

Currently, there are five API URLs:

https://streetcred.herokuapp.com/api/actions (generic create)
https://streetcred.herokuapp.com/api/actions/citizens_connect
https://streetcred.herokuapp.com/api/actions/email
https://streetcred.herokuapp.com/api/actions/foursquare
https://streetcred.herokuapp.com/api/actions/street_bump

New adapters can be written in api/actions_controller.rb.  A matching route must also be added to config/routes.rb

The generic create method accepts the following parameters:
  
Required parameters:
- :api_key
- :action_type
- :email

Optional parameters:
- :description
- :shared (Boolean)
- :latitude, type: BigDecimal
- :longitude, type: BigDecimal
- :address
- :city
- :zipcode
- :state
- :url

CURL
-------------

Test the API using curl:

curl -X POST -H "Content-Type: application/json" -d '{"api_key":"apikeyhere", "action_type":"Patch Report","email":"youremail@gmail.com","latitude":"42.359885","longitude":"-71.057983"}' http://streetcred.us/api/actions.json

Or download the Postman REST Client Chrome extension: https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm?hl=en