# frozen_string_literal: true

module HasCapability
  extend ActiveSupport::Concern

  included do
    enum :capability, {
      deep:     0,  # sustained focus, complex reasoning
      light:    1,  # simple tasks, low cognitive load
      social:   2,  # calls, meetings, conversations
      admin:    3,  # email, paperwork, logistics
      physical: 4,  # exercise, errands, movement
      creative: 5   # writing, design, open-ended thinking
    }, validate: { allow_nil: true }
  end
end
