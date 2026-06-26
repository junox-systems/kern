class CreateCalendars < ActiveRecord::Migration[8.1]
  def change
    create_table :calendars, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
