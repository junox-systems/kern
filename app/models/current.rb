class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :operator, to: :session, allow_nil: true
end
