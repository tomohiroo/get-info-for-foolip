require 'open-uri'

class Foursquare
  def self.search(params)
    conn = Faraday.new url: 'https://api.foursquare.com/v2/venues/search'
    conn.get do |req|
      req.params[:client_id] = $client_id
      req.params[:client_secret] = $client_secret
      req.params[:v] = ENV['foursquare_version']
      req.params[:locale] = 'ja'
      req.params[:intent] = 'browse'
      req.params[:ll] = params[:ll]
      req.params[:limit] = params[:limit]
      req.params[:radius] = params[:radius]
      req.params[:categoryId] = params[:categoryId]
    end
  end

  def self.details(ids)
    restaurant_hashes = []
    ids.each do |id|
      conn = Faraday.new url: "https://api.foursquare.com/v2/venues/#{id}"
      response = conn.get do |req|
        req.params[:client_id] = $client_id
        req.params[:client_secret] = $client_secret
        req.params[:v] = ENV['foursquare_version']
        req.params[:locale] = 'ja'
      end
      status = JSON.parse(response.body)['meta']['code']
      return status if status == 429

      venue = JSON.parse(response.body)['response']['venue']
      if venue.blank? || venue['id'].blank?
        msg = "venueがnilのerrorが起きました。\nfoursquare_id: #{id}\nvenue: #{venue}\nresponse_code: #{status}\nbody: #{JSON.parse(response.body)}"
        SlackNotify.notify msg
        puts msg
        next
      end
      new_restaurant, category, pictures, station = Restaurant.build_with_foursquare_hash venue
      detail = new_restaurant.attributes
      detail[:category] = category
      detail[:pictures] = pictures
      detail[:station] = station
      restaurant_hashes << { restaurant: new_restaurant, detail: detail }
      sleep rand(3)
    end

    restaurant_hashes
  end

end
