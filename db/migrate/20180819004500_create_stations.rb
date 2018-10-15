class CreateStations < ActiveRecord::Migration[5.2]
  def change
    create_table :stations do |t|
      t.string :name
      t.string :roman
      t.string :prefecture
      t.decimal :lat, :precision => 9, :scale => 6
      t.decimal :lng, :precision => 9, :scale => 6

      t.timestamps
    end
    add_index :stations, :name
    add_index :stations, :roman
    add_index :stations, [:lat, :lng]
  end
end
