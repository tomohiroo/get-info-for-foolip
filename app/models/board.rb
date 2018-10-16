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

class Board < ApplicationRecord
  belongs_to :user
  has_many :clip_categories, dependent: :destroy
  has_many :clips, through: :clip_categories
end
