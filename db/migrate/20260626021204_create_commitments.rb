class CreateCommitments < ActiveRecord::Migration[8.1]
  def change
    create_table :commitments, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :category, null: true, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :description
      t.text :context
      t.integer :capability
      t.integer :estimate_minutes
      t.datetime :due_at
      t.datetime :available_after
      t.integer :state, null: false, default: 0

      t.timestamps
    end

    add_index :commitments, [:user_id, :state]
    add_index :commitments, [:user_id, :category_id, :state]
    add_index :commitments, [:category_id, :state]
    add_index :commitments, :due_at
    add_index :commitments, :available_after
  end
end
