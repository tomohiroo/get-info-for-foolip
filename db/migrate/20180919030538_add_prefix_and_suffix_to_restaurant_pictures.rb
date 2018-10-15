class AddPrefixAndSuffixToRestaurantPictures < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_pictures, :prefix, :string
    add_column :restaurant_pictures, :suffix, :string
  end
end
