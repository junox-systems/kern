class OperatorEvent < ApplicationRecord
  belongs_to :user
  belongs_to :commitment, optional: true

  enum :event_type, {
    capture:  0,
    complete: 1,
    defer:    2,
    archive:  3
  }, default: :capture, validate: true
end
