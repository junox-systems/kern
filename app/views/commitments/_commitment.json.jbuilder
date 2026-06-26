json.extract! commitment, :id, :user_id, :category_id, :title, :description, :context, :capability, :estimate_minutes, :due_at, :available_after, :state, :created_at, :updated_at
json.url commitment_url(commitment, format: :json)
