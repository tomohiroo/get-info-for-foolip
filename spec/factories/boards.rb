# encoding: utf-8
# == Schema Information
#
# Table name: boards
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#
# Indexes
#
#  index_boards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :board do

    trait :board_1 do
      name 'おしゃれなカフェ集'
      association :user
    end

    trait :board_2 do
      name 'おしゃれなカフェ集'
      association :user, factory: :other_user
    end

  end
end
