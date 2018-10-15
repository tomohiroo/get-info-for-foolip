class CreateRestaurantPictures < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_pictures do |t|
      t.string :foursquare_id
      t.string :picture
      t.references :restaurant, foreign_key: true

      t.timestamps
    end
    add_index :restaurant_pictures, :foursquare_id, unique: true
  end
end
