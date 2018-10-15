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

require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it "is invalid without name" do
    restaurant = Restaurant.new(
      name: nil
    )
    restaurant.valid?
    expect(restaurant.errors[:name]).to include "can't be blank"
  end

  it "allows it doesn't have category_id" do
    restaurant = Restaurant.new(
      category_id: nil
    )
    restaurant.valid?
    expect(restaurant.errors[:category_id]).to be_empty
  end
end
