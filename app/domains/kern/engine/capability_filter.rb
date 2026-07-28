# frozen_string_literal: true

module Kern
  module Engine
    # Matches commitment capabilities to the current block's capability.
    # A commitment requiring deep focus will never be recommended during a light block.
    # Pure function — no database access.
    class CapabilityFilter
      def initialize(commitments, current_block)
        @commitments = commitments
        @current_block = current_block
      end

      # Returns filtered array of capability-matched commitments.
      def apply
        # No current block = untyped time. Accept all commitments.
        return @commitments if @current_block.nil?

        # Block has no capability = accepts anything.
        return @commitments if @current_block.capability.nil?

        @commitments.select { |c| matches?(c) }
      end

      private

      def matches?(commitment)
        # Commitment has no capability requirement = matches any block.
        return true if commitment.capability.nil?

        commitment.capability == @current_block.capability
      end
    end
  end
end
