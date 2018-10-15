# == Schema Information
#
# Table name: restaurants
#
#  id             :bigint(8)        not null, primary key
#  address        :string
#  foursquare_url :string
#  lat            :decimal(9, 6)
#  lng            :decimal(9, 6)
#  name           :string
#  phone          :string
#  price          :integer
#  rating         :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :bigint(8)
#  facebook_id    :string
#  foursquare_id  :string
#  instagram_id   :string
#  station_id     :bigint(8)
#  twitter_id     :string
#
# Indexes
#
#  index_restaurants_on_category_id    (category_id)
#  index_restaurants_on_foursquare_id  (foursquare_id) UNIQUE
#  index_restaurants_on_station_id     (station_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (station_id => stations.id)
#

class Restaurant < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :station
  has_many :restaurant_pictures, dependent: :destroy
  has_many :clips, dependent: :destroy
  has_many :users, through: :clips
  validates :foursquare_id, presence: true
  validates :name, presence: true
  acts_as_mappable

  def self.search params
    response = Foursquare.search params
    return response.status if response.status != 200
    restaurants = JSON.parse(response.body)["response"]["venues"]
    foursquare_ids = restaurants.map { |h| h["id"] }
    in_db_restaurants = Restaurant.includes([:category, :restaurant_pictures, :station])
      .where(foursquare_id: foursquare_ids)
    in_db_restaurants_foursquare_ids = in_db_restaurants.map(&:foursquare_id)
    new_restaurants_foursquare_ids = foursquare_ids.select { |id| in_db_restaurants_foursquare_ids.exclude? id }
    new_restaurants_hash = Foursquare.get_details new_restaurants_foursquare_ids
    return 429 if new_restaurants_hash == 429
    Restaurant.import new_restaurants_hash.map { |h| h[:restaurant] }, recursive: true, validate: false
    in_db_restaurants_details = in_db_restaurants.map(&:get_details_from_db)
    new_restaurants_details = new_restaurants_hash.map { |h| h[:detail] }
    results = in_db_restaurants_details.concat(new_restaurants_details)
    results.sort { |a,b| foursquare_ids.index(a["foursquare_id"]) <=> foursquare_ids.index(b["foursquare_id"]) }
  end

  def get_details_from_db
    details = attributes
    details[:category] = category if category
    details[:pictures] = restaurant_pictures.sort { |a,b| a.id <=> b.id } if restaurant_pictures
    details[:station] = station
    return details
  end

  private

    def self.build_with_foursquare_hash venue
      new_restaurant = Restaurant.new
      new_restaurant.foursquare_id = venue["id"]
      new_restaurant.name = venue["name"] if venue["name"]
      new_restaurant.phone = "0#{venue["contact"]["phone"][3..-1]}" if venue["contact"]["phone"]
      new_restaurant.twitter_id = venue["contact"]["twitter"] if venue["contact"]["twitter"]
      new_restaurant.facebook_id = venue["contact"]["facebook"] if venue["contact"]["facebook"]
      new_restaurant.instagram_id = venue["contact"]["instagram"] if venue["contact"]["instagram"]
      new_restaurant.lat = venue["location"]["lat"]
      new_restaurant.lng = venue["location"]["lng"]
      new_restaurant.address = venue["location"]["formattedAddress"][0..-2]
        .map { |a| a.split ', ' }.flatten.reverse.join(' ') if venue["location"]["formattedAddress"]
      new_restaurant.foursquare_url = venue["canonicalUrl"] if venue["canonicalUrl"]
      new_restaurant.rating = venue["rating"] / 2 if venue["rating"]
      new_restaurant.price = venue["price"]["tier"] if venue["price"] && venue["price"]["tier"]
      new_restaurant.category = Category.build_with_foursquare_hash venue["categories"][0] if venue["categories"][0]
      new_restaurant.restaurant_pictures = RestaurantPicture.build_with_foursquare_hash venue["photos"] unless venue["photos"]["count"] == 0
      new_restaurant.station = Station.closest(origin: [new_restaurant.lat, new_restaurant.lng])[0]
      return new_restaurant, new_restaurant.category, new_restaurant.restaurant_pictures, new_restaurant.station
    end

end
