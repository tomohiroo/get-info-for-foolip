# == Schema Information
#
# Table name: stations
#
#  id         :bigint(8)        not null, primary key
#  lat        :decimal(9, 6)
#  lng        :decimal(9, 6)
#  name       :string
#  prefecture :string
#  roman      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stations_on_lat_and_lng  (lat,lng)
#  index_stations_on_name         (name)
#  index_stations_on_roman        (roman)
#

class Station < ApplicationRecord
  has_many :restaurants

  acts_as_mappable

end
