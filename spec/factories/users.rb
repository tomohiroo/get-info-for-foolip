# == Schema Information
#
# Table name: users
#
#  id                 :bigint(8)        not null, primary key
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#  access_token       :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :user do
  end

  factory :other_user, class: User do
  end
end
