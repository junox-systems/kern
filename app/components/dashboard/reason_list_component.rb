# frozen_string_literal: true

module Dashboard
  class ReasonListComponent < ViewComponent::Base
    def initialize(reasons:)
      @reasons = reasons || []
    end

    def render?
      @reasons.any?
    end
  end
end
