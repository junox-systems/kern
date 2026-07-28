class RenameUsersToOperators < ActiveRecord::Migration[8.0]
  def change
    rename_table :users, :operators

    rename_column :sessions, :user_id, :operator_id
    rename_column :categories, :user_id, :operator_id
    rename_column :commitments, :user_id, :operator_id
    rename_column :calendars, :user_id, :operator_id
    rename_column :calendar_blocks, :user_id, :operator_id
    rename_column :operator_events, :user_id, :operator_id
    rename_column :block_schedules, :user_id, :operator_id
  end
end
