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

  def self.search(params)
    response = Foursquare.search params
    return response.status if response.status != 200
    restaurants = JSON.parse(response.body)["response"]["venues"]
    foursquare_ids = restaurants.map { |h| h["id"] }
    in_db_restaurants = Restaurant.includes([:category, :restaurant_pictures, :station]).where(foursquare_id: foursquare_ids)
    in_db_restaurants_foursquare_ids = in_db_restaurants.map(&:foursquare_id)
    new_restaurants_foursquare_ids = foursquare_ids.select { |id| in_db_restaurants_foursquare_ids.exclude? id }
    new_restaurants_hash = Foursquare.get_details new_restaurants_foursquare_ids
    return 429 if new_restaurants_hash == 429
    Restaurant.import new_restaurants_hash.map { |h| h[:restaurant] }, recursive: true, validate: false
    in_db_restaurants_details = in_db_restaurants.map(&:get_details_from_db)
    new_restaurants_details = new_restaurants_hash.map { |h| h[:detail] }
    results = in_db_restaurants_details.concat(new_restaurants_details)
    results.sort_by { |rst| foursquare_ids.index(rst["foursquare_id"]) }
  end

  def get_details_from_db
    details = attributes
    details[:category] = category if category
    details[:pictures] = restaurant_pictures.sort_by(&:id) if restaurant_pictures
    details[:station] = station
    details
  end

  def self.build_with_foursquare_hash(venue)
    new_restaurant = Restaurant.new
    new_restaurant.foursquare_id = venue["id"]
    new_restaurant.name = venue["name"] if venue["name"]
    new_restaurant.phone = "0#{venue["contact"]["phone"][3..-1]}" if venue["contact"]["phone"]
    new_restaurant.twitter_id = venue["contact"]["twitter"] if venue["contact"]["twitter"]
    new_restaurant.facebook_id = venue["contact"]["facebook"] if venue["contact"]["facebook"]
    new_restaurant.instagram_id = venue["contact"]["instagram"] if venue["contact"]["instagram"]
    new_restaurant.lat = venue["location"]["lat"]
    new_restaurant.lng = venue["location"]["lng"]
    new_restaurant.address = venue["location"]["formattedAddress"][0..-2].map { |a| a.split ', ' }.flatten.reverse.join(' ') if venue["location"]["formattedAddress"]
    new_restaurant.foursquare_url = venue["canonicalUrl"] if venue["canonicalUrl"]
    new_restaurant.rating = venue["rating"] / 2 if venue["rating"]
    new_restaurant.price = venue["price"]["tier"] if venue["price"] && venue["price"]["tier"]
    new_restaurant.get_tabelog_url
    new_restaurant.category = Category.build_with_foursquare_hash venue["categories"][0] if venue["categories"][0]
    new_restaurant.restaurant_pictures = RestaurantPicture.build_with_foursquare_hash venue["photos"] if venue["photos"]["count"].positive?
    new_restaurant.station = Station.closest(origin: [new_restaurant.lat, new_restaurant.lng])[0]
    return new_restaurant, new_restaurant.category, new_restaurant.restaurant_pictures, new_restaurant.station
  end

  private

    def get_tabelog_url
      agent = Mechanize.new
      agent.user_agent_alias = 'iPhone'
      agent.request_headers = {
          'accept-language' => 'ja,en-US;q=0.8,en;q=0.6,zh-CN;q=0.4,zh;q=0.2',
          'Upgrade-Insecure-Requests' => '1',
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      }
      page = agent.get "https://s.tabelog.com/smartphone/restaurant_list/list?utf8=%E2%9C%93&SrtT=rt&tid=&sk=#{name}&svd=20181118&svps=2&svt=1900&LstCos=0&LstCosT=0&LstRev=&LstSitu=0&LstSmoking=0&area_datatype=&area_id=&keyword_datatype=&keyword_id=&LstReserve=0&lat=#{lat}&lon=#{lng}&LstRange=A&lid=redo_search_form&additional_cond_flg=1"
      not_found_msgs = [page.at('#page-header > div.searchword'), page.at('#js-parent-of-floating-element > p')]
      if (not_found_msgs[0] && not_found_msgs[0].children[1]['class'] == 'rstname-notfound') || (not_found_msgs[1] && not_found_msgs[1].attributes['class'].value == 'not-found')
        tabelog_url = ''
      else
        uri = URI.parse(page.at('#js-parent-of-floating-element > div.rst-list-group-wrap.js-rst-list-group-wrap > section > div > a').attributes['href'].value)
        uri.host = 'tabelog.com' if uri.host == 's.tabelog.com'
        uri.query = nil
        tabelog_url = uri.to_s
      end
    end

end
