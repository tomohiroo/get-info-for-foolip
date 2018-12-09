class Category < ApplicationRecord
  has_many :restaurants

  validates :foursquare_id, presence: true
  validates :name, presence: true

  def self.build_with_foursquare_hash(category)
    if response = Category.find_by(foursquare_id: category['id'])
      return response
    end

    Category.save_category_with_foursquare_hash category
  end

  private

    def self.save_category_with_foursquare_hash(category)
      new_category = Category.new
      new_category.foursquare_id = category['id']
      new_category.name = category['name']
      new_category.short_name = category['shortName']
      new_category.save!
      new_category
    end

end
