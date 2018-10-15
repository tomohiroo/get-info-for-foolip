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

class Category < ApplicationRecord
  has_many :restaurants

  validates :foursquare_id, presence: true
  validates :name, presence: true

  def self.build_with_foursquare_hash category
    if response = Category.find_by(foursquare_id: category["id"])
      return response
    end
    Category.save_category_with_foursquare_hash category
  end

  private

    def self.save_category_with_foursquare_hash category
      new_category = Category.new
      new_category.foursquare_id = category["id"]
      new_category.name = category["name"]
      new_category.short_name = category["shortName"]
      new_category.save!
      new_category
    end

end
