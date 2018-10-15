class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :foursquare_id
      t.string :name
      t.string :phone
      t.string :twitter_id
      t.string :facebook_id
      t.string :instagram_id
      t.decimal :lat, :precision => 9, :scale => 6
      t.decimal :lng, :precision => 9, :scale => 6
      t.string :address
      t.string :foursquare_url
      t.float :rating
      t.integer :price
      t.references :category, foreign_key: true
      t.references :station, foreign_key: true

      t.timestamps
    end
    add_index :restaurants, :foursquare_id, unique: true
  end
end
