# frozen_string_literal: true

module Shared
  class CapabilityBadgeComponent < ViewComponent::Base
    def initialize(capability:, size: :sm)
      @capability = capability
      @size = size
    end

    def render?
      @capability.present?
    end

    def badge_class
      case @size
      when :xs then "badge-xs"
      when :sm then "badge-sm"
      when :lg then "badge-lg"
      else "badge-sm"
      end
    end
  end
end
