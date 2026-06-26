class CreateBlockSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :block_schedules, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :calendar, null: false, foreign_key: true, type: :uuid
      t.references :category, null: false, foreign_key: true, type: :uuid
      t.integer :capability
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.json :days_of_week, null: false, default: []
      t.date :effective_from
      t.date :effective_until
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :block_schedules, [:user_id, :active]
  end
end
