json.extract! calendar_block, :id, :user_id, :calendar_id, :category_id, :block_schedule_id, :capability, :date, :start_time, :end_time, :block_type, :external_uid, :created_at, :updated_at
json.url calendar_block_url(calendar_block, format: :json)
