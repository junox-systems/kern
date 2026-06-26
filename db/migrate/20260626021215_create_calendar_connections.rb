class CreateCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_connections, id: :uuid do |t|
      t.references :calendar, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false, default: "google"
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at
      t.string :external_calendar_id

      t.timestamps
    end
  end
end
