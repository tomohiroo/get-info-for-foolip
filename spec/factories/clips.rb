# encoding: utf-8
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

FactoryBot.define do
  factory :clip do
    trait :clip_1 do
      memo 'イタリアン美味しかった'
      rating 3.5
      has_visit true
      association :user
      association :restaurant, factory: :restaurant_1
    end

    trait :clip_2 do
      memo 'お酒美味しかった'
      rating 3.5
      has_visit true
      association :user, factory: :other_user
      association :restaurant, factory: :restaurant_2
    end

    trait :clip_3 do
      memo 'カフェ美味しかった'
      rating 3.5
      has_visit true
      association :user
      association :restaurant, factory: :restaurant_3
    end

    trait :clip_4 do
      memo 'ラーメン美味しかった'
      rating 3.5
      has_visit true
      association :user
      association :restaurant, factory: :restaurant_4
    end
  end

end
