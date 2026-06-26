# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_26_052517) do
  create_table "block_schedules", id: uuid, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "calendar_id", limit: 36, null: false
    t.integer "capability"
    t.string "category_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.json "days_of_week", default: [], null: false
    t.date "effective_from"
    t.date "effective_until"
    t.time "end_time", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["calendar_id"], name: "index_block_schedules_on_calendar_id"
    t.index ["category_id"], name: "index_block_schedules_on_category_id"
    t.index ["user_id", "active"], name: "index_block_schedules_on_user_id_and_active"
    t.index ["user_id"], name: "index_block_schedules_on_user_id"
  end

  create_table "calendar_blocks", id: uuid, force: :cascade do |t|
    t.string "block_schedule_id", limit: 36
    t.integer "block_type", default: 0, null: false
    t.string "calendar_id", limit: 36, null: false
    t.integer "capability"
    t.string "category_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time", null: false
    t.string "external_uid"
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["block_schedule_id"], name: "index_calendar_blocks_on_block_schedule_id"
    t.index ["calendar_id", "date"], name: "index_calendar_blocks_on_calendar_id_and_date"
    t.index ["calendar_id"], name: "index_calendar_blocks_on_calendar_id"
    t.index ["category_id", "date"], name: "index_calendar_blocks_on_category_id_and_date"
    t.index ["category_id"], name: "index_calendar_blocks_on_category_id"
    t.index ["external_uid"], name: "index_calendar_blocks_on_external_uid", unique: true
    t.index ["user_id", "date"], name: "index_calendar_blocks_on_user_id_and_date"
    t.index ["user_id"], name: "index_calendar_blocks_on_user_id"
  end

  create_table "calendar_connections", id: uuid, force: :cascade do |t|
    t.string "access_token"
    t.string "calendar_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "external_calendar_id"
    t.string "provider", default: "google", null: false
    t.string "refresh_token"
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_calendar_connections_on_calendar_id"
  end

  create_table "calendars", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "categories", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.text "description"
    t.string "name", null: false
    t.string "parent_id", limit: 36
    t.integer "priority", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.integer "weekly_allocation_minutes", default: 0, null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["user_id", "priority"], name: "index_categories_on_user_id_and_priority"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "commitment_dependencies", id: uuid, force: :cascade do |t|
    t.string "commitment_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.string "depends_on_id", limit: 36, null: false
    t.datetime "updated_at", null: false
    t.index ["commitment_id", "depends_on_id"], name: "index_commitment_deps_on_commitment_and_depends_on", unique: true
    t.index ["commitment_id"], name: "index_commitment_dependencies_on_commitment_id"
    t.index ["depends_on_id"], name: "index_commitment_dependencies_on_depends_on_id"
  end

  create_table "commitments", id: uuid, force: :cascade do |t|
    t.datetime "available_after"
    t.integer "capability"
    t.string "category_id", limit: 36
    t.text "context"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "due_at"
    t.integer "estimate_minutes"
    t.integer "state", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["available_after"], name: "index_commitments_on_available_after"
    t.index ["category_id", "state"], name: "index_commitments_on_category_id_and_state"
    t.index ["category_id"], name: "index_commitments_on_category_id"
    t.index ["due_at"], name: "index_commitments_on_due_at"
    t.index ["user_id", "category_id", "state"], name: "index_commitments_on_user_id_and_category_id_and_state"
    t.index ["user_id", "state"], name: "index_commitments_on_user_id_and_state"
    t.index ["user_id"], name: "index_commitments_on_user_id"
  end

  create_table "operator_events", id: uuid, force: :cascade do |t|
    t.string "commitment_id", limit: 36
    t.datetime "created_at", null: false
    t.integer "event_type", default: 0, null: false
    t.json "metadata"
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["commitment_id", "created_at"], name: "index_operator_events_on_commitment_id_and_created_at"
    t.index ["commitment_id"], name: "index_operator_events_on_commitment_id"
    t.index ["user_id", "event_type", "created_at"], name: "index_operator_events_on_user_id_and_event_type_and_created_at"
    t.index ["user_id"], name: "index_operator_events_on_user_id"
  end

  create_table "sessions", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "user_id", limit: 36, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "block_schedules", "calendars"
  add_foreign_key "block_schedules", "categories"
  add_foreign_key "block_schedules", "users"
  add_foreign_key "calendar_blocks", "block_schedules"
  add_foreign_key "calendar_blocks", "calendars"
  add_foreign_key "calendar_blocks", "categories"
  add_foreign_key "calendar_blocks", "users"
  add_foreign_key "calendar_connections", "calendars"
  add_foreign_key "calendars", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories", "users"
  add_foreign_key "commitment_dependencies", "commitments"
  add_foreign_key "commitment_dependencies", "commitments", column: "depends_on_id"
  add_foreign_key "commitments", "categories"
  add_foreign_key "commitments", "users"
  add_foreign_key "operator_events", "commitments"
  add_foreign_key "operator_events", "users"
  add_foreign_key "sessions", "users"
end
