json.extract! category, :id, :user_id, :parent_id, :name, :description, :priority, :weekly_allocation_minutes, :depth, :created_at, :updated_at
json.url category_url(category, format: :json)
