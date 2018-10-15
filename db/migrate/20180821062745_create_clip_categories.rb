class CreateClipCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :clip_categories do |t|
      t.references :clip, foreign_key: true
      t.references :board, foreign_key: true

      t.timestamps
    end
    add_index :clip_categories, [:clip_id, :board_id], unique: true
  end
end
