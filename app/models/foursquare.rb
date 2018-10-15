class Foursquare

  @domain = "https://api.foursquare.com/v2"

  def self.search params
    if params[:ll].present?
      checkin_search params
    else
      search_japan params
    end
  end

  def self.get_details ids
    hydra = Typhoeus::Hydra.new
    restaurant_hashes = []
    ids.each do |id|
      request = Typhoeus::Request.new(
        "#{@domain}/venues/#{id}",
        followlocation: true,
        params: {
          client_id: Rails.application.secrets.foursquare_client_id,
          client_secret: Rails.application.secrets.foursquare_client_secret,
          v: Rails.application.secrets.foursquare_version,
          locale: "ja"
        }
      )
      request.on_complete do |response|
        status = JSON.parse(response.body)["meta"]["code"]
        return status if status == 429
        venue = JSON.parse(response.body)["response"]["venue"]
        new_restaurant, category, pictures, station = Restaurant.build_with_foursquare_hash venue
        detail = new_restaurant.attributes
        detail[:category] = category
        detail[:pictures] = pictures
        detail[:station] = station
        restaurant_hashes << { restaurant: new_restaurant, detail: detail }
      end
      hydra.queue(request)
    end
    hydra.run
    restaurant_hashes
  end

  private

    def self.set_default_params(req)
      req.params[:client_id] = Rails.application.secrets.foursquare_client_id
      req.params[:client_secret] = Rails.application.secrets.foursquare_client_secret
      req.params[:v] = Rails.application.secrets.foursquare_version
      req.params[:locale] = "ja"
    end

    def self.checkin_search params
      conn = Faraday.new(url: "#{@domain}/venues/search")
      conn.get do |req|
        set_default_params req
        req.params[:ll] = params[:ll]
        req.params[:query] = params[:query] if params[:query].present?
        req.params[:limit] = params[:limit] if params[:limit].present?
        req.params[:radius] = params[:radius] if params[:radius].present?
        req.params[:categoryId] = params[:categoryId] if params[:categoryId].present?
      end
    end

    def self.search_japan params
      conn = Faraday.new(url: "#{@domain}/venues/search")
      conn.get do |req|
        set_default_params req
        req.params[:intent] = "browse"
        req.params[:query] = params[:query] if params[:query].present?
        req.params[:near] = "日本"
        req.params[:limit] = params[:limit] if params[:limit].present?
        req.params[:categoryId] = params[:categoryId] if params[:categoryId].present?
      end
    end

end
