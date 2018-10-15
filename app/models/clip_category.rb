# == Schema Information
#
# Table name: clip_categories
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  board_id   :bigint(8)
#  clip_id    :bigint(8)
#
# Indexes
#
#  index_clip_categories_on_board_id              (board_id)
#  index_clip_categories_on_clip_id               (clip_id)
#  index_clip_categories_on_clip_id_and_board_id  (clip_id,board_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (board_id => boards.id)
#  fk_rails_...  (clip_id => clips.id)
#

class ClipCategory < ApplicationRecord
  belongs_to :clip
  belongs_to :board
end
