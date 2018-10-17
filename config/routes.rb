Rails.application.routes.draw do
  post '/get_restaurants', to: 'crawling#foursquare'
end
