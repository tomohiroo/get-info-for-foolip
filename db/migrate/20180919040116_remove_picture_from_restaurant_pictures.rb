class RemovePictureFromRestaurantPictures < ActiveRecord::Migration[5.2]
  def change
    remove_column :restaurant_pictures, :picture, :string
  end
end
