# == Schema Information
#
# Table name: clips
#
#  id            :bigint(8)        not null, primary key
#  has_visit     :boolean          default(FALSE), not null
#  memo          :text
#  rating        :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  restaurant_id :bigint(8)
#  user_id       :bigint(8)
#
# Indexes
#
#  index_clips_on_restaurant_id              (restaurant_id)
#  index_clips_on_user_id                    (user_id)
#  index_clips_on_user_id_and_restaurant_id  (user_id,restaurant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (restaurant_id => restaurants.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Clip, type: :model do

  it "is invalid without user" do
    clip = Clip.new(
      user: nil
    )
    clip.valid?
    expect(clip.errors[:user]).to include "can't be blank"
  end

  it "is invalid without restaurant" do
    clip = Clip.new(
      restaurant: nil
    )
    clip.valid?
    expect(clip.errors[:restaurant]).to include "can't be blank"
  end

  describe "connects users and restaurants" do
    before do
      @user = User.create()
      @category = Category.create(
        foursquare_id: '4bf58dd8d48988d110941735',
        name: 'イタリア料理店',
        short_name: 'イタリア料理'
      )
      @restaurant = Restaurant.create(
        foursquare_id: '538ac507498e2936ab978f18',
        name: '俺のイタリアン KABUKICHO',
        phone: '+81332086530',
        lat: 35.694194,
        lng: 139.701179,
        address: "[\"歌舞伎町1-17-5\", \"新宿区, 東京都\", \"160-0021\", \"日本\"]",
        foursquare_url: "https://foursquare.com/v/%E4%BF%BA%E3%81%AE%E3%82%A4%E3%82%BF%E3%83%AA%E3%82%A2%E3%83%B3-kabukicho/538ac507498e2936ab978f18",
        rating: 3.45,
        price: 2,
        category: @category
      )
      Clip.create(
        user: @user,
        restaurant: @restaurant,
        memo: '美味しかった。',
        rating: 4.0,
        has_visit: true
      )
    end

    it "has connected user and restaurants" do
      restaurants = @user.restaurants
      expect(restaurants[0]).to eq @restaurant
    end

  end
end
