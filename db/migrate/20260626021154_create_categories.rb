class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :parent, type: :uuid, foreign_key: { to_table: :categories }
      t.string :name, null: false
      t.text :description
      t.integer :priority, null: false, default: 0
      t.integer :weekly_allocation_minutes, null: false, default: 0
      t.integer :depth, null: false, default: 0

      t.timestamps
    end

    add_index :categories, [:user_id, :priority]
  end
end
