# == Schema Information
#
# Table name: restaurant_pictures
#
#  id            :bigint(8)        not null, primary key
#  prefix        :string
#  suffix        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  foursquare_id :string
#  restaurant_id :bigint(8)
#
# Indexes
#
#  index_restaurant_pictures_on_foursquare_id  (foursquare_id) UNIQUE
#  index_restaurant_pictures_on_restaurant_id  (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (restaurant_id => restaurants.id)
#

class RestaurantPicture < ApplicationRecord
  belongs_to :restaurant
  validates :prefix, presence: true
  validates :suffix, presence: true
  validates :restaurant_id, presence: true

  def self.build_with_foursquare_hash(hash)
    puts hash['groups']
    items = hash['groups'][1]['items']
    items.map do |item|
      RestaurantPicture.new(
        foursquare_id: item['id'],
        prefix: item['prefix'],
        suffix: item['suffix']
      )
    end
  end

end
