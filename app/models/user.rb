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

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :validatable

  devise :trackable

  after_create :update_access_token!

  has_many :clips, dependent: :destroy
  has_many :restaurants, through: :clips
  has_many :boards
end
