class AddUrlsToRestaurant < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :tabelog_url, :string
    add_column :restaurants, :instagram_url, :string
  end
end
