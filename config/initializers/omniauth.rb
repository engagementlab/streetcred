Rails.application.config.middleware.use OmniAuth::Builder do
  provider :foursquare, ENV['FOURSQUARE_ID'], ENV['FOURSQUARE_SECRET']
end