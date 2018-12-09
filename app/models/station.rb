class Station < ApplicationRecord
  has_many :restaurants

  acts_as_mappable

end
