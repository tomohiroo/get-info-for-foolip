class RestaurantPicture < ApplicationRecord
  belongs_to :restaurant
  validates :prefix, presence: true
  validates :suffix, presence: true
  validates :restaurant_id, presence: true

  def self.build_with_foursquare_hash(hash)
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
