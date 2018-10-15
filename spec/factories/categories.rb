# == Schema Information
#
# Table name: categories
#
#  id            :bigint(8)        not null, primary key
#  name          :string
#  roman         :string
#  short_name    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  foursquare_id :string
#
# Indexes
#
#  index_categories_on_foursquare_id  (foursquare_id) UNIQUE
#  index_categories_on_name           (name)
#  index_categories_on_roman          (roman)
#

FactoryBot.define do
  factory :category_1 , class: Category do
    foursquare_id '4bf58dd8d48988d110941735'
    name 'イタリア料理店'
    short_name 'イタリア料理'
  end

  factory :category_2 , class: Category do
    foursquare_id '4bf58dd8d48988d11c941735'
    name '居酒屋'
    short_name '居酒屋'
  end

  factory :category_3 , class: Category do
    foursquare_id '4bf58dd8d48988d16d941735'
    name 'カフェ'
    short_name 'カフェ'
  end

  factory :category_4 , class: Category do
    foursquare_id '55a59bace4b013909087cb24'
    name 'ラーメン屋'
    short_name 'ラーメン'
  end
end
