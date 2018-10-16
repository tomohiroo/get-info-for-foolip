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

class Clip < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user
  validates :restaurant, presence: true
  validates :user, presence: true
  has_many :clip_categories, dependent: :destroy
  has_many :boards, through: :clip_categories
end
