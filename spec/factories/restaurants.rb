# encoding: utf-8
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

FactoryBot.define do
  factory :restaurant_1 , class: Restaurant do
    foursquare_id '538ac507498e2936ab978f18'
    name '俺のイタリアン KABUKICHO'
    phone '+81332086530'
    lat 35.694194
    lng 139.701179
    address "[\"歌舞伎町1-17-5\", \"新宿区, 東京都\", \"160-0021\", \"日本\"]"
    foursquare_url "https://foursquare.com/v/%E4%BF%BA%E3%81%AE%E3%82%A4%E3%82%BF%E3%83%AA%E3%82%A2%E3%83%B3-kabukicho/538ac507498e2936ab978f18"
    rating 3.45
    price 2
    association :category, factory: :category_1
  end

  factory :restaurant_2 , class: Restaurant do
    foursquare_id '5350a8e5498e69bb5623a102'
    name '居酒屋 喜楽'
    phone nil
    lat 35.656178
    lng 139.70552
    address "[\"渋谷3-15-2 (コンパルビル5F)\", \"渋谷区, 東京都\", \"日本\"]"
    foursquare_url "https://foursquare.com/v/%E4%BF%BA%E3%81%AE%E3%82%A4%E3%82%BF%E3%83%AA%E3%82%A2%E3%83%B3-kabukicho/538ac507498e2936ab978f18"
    rating nil
    price 2
    association :category, factory: :category_2
  end

  factory :restaurant_3 , class: Restaurant do
    foursquare_id '4ba6e28af964a520717539e3'
    name 'ITALIAN TOMATO Cafe Jr. 西武新宿駅店'
    phone "+81352855224"
    lat 35.695964
    lng 139.700188
    address "[\"歌舞伎町1-30-1 (アメリカン・ブルバード 1F)\", \"新宿区, 東京都\", \"160-0021\", \"日本\"]"
    foursquare_url "https://foursquare.com/v/italian-tomato-cafe-jr-%E8%A5%BF%E6%AD%A6%E6%96%B0%E5%AE%BF%E9%A7%85%E5%BA%97/4ba6e28af964a520717539e3"
    rating nil
    price 1
    association :category, factory: :category_3
  end

  factory :restaurant_4 , class: Restaurant do
    foursquare_id '5b08d6d52db4a9002c7759ce'
    name '横浜家系ラーメン 横浜道 渋谷店'
    phone nil
    lat 35.658974
    lng 139.69812
    address "[\"道玄坂2-9-10\", \"渋谷区, 東京都\", \"150-0043\", \"日本\"]"
    foursquare_url "https://foursquare.com/v/%E6%A8%AA%E6%B5%9C%E5%AE%B6%E7%B3%BB%E3%83%A9%E3%83%BC%E3%83%A1%E3%83%B3-%E6%A8%AA%E6%B5%9C%E9%81%93-%E6%B8%8B%E8%B0%B7%E5%BA%97/5b08d6d52db4a9002c7759ce"
    rating nil
    price nil
    association :category, factory: :category_4
  end

end
