class CreateOperatorEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :operator_events, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :commitment, null: true, foreign_key: true, type: :uuid
      t.integer :event_type, null: false, default: 0
      t.json :metadata

      t.timestamps
    end

    add_index :operator_events, [:user_id, :event_type, :created_at]
    add_index :operator_events, [:commitment_id, :created_at]
  end
end
