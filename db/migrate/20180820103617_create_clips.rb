class CreateClips < ActiveRecord::Migration[5.2]
  def change
    create_table :clips do |t|
      t.references :restaurant, foreign_key: true
      t.references :user, foreign_key: true
      t.text :memo
      t.float :rating
      t.boolean :has_visit, default: false, null: false

      t.timestamps
    end
    add_index :clips, [:user_id, :restaurant_id], unique: true
  end
end
