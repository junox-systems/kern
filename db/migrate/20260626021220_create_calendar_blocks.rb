class CreateCalendarBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_blocks, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :calendar, null: false, foreign_key: true, type: :uuid
      t.references :category, null: false, foreign_key: true, type: :uuid
      t.references :block_schedule, null: true, foreign_key: true, type: :uuid
      t.integer :capability
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :block_type, null: false, default: 0
      t.string :external_uid

      t.timestamps
    end

    add_index :calendar_blocks, [:user_id, :date]
    add_index :calendar_blocks, [:calendar_id, :date]
    add_index :calendar_blocks, [:category_id, :date]
    add_index :calendar_blocks, :external_uid, unique: true
  end
end
