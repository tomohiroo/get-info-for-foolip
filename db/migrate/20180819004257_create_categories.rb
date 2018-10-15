class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :foursquare_id
      t.string :name
      t.string :short_name
      t.string :roman

      t.timestamps
    end
    add_index :categories, :foursquare_id, unique: true
    add_index :categories, :name
    add_index :categories, :roman
  end
end
