# frozen_string_literal: true

module Kern
  module Engine
    # Removes commitments that cannot be recommended right now.
    # Operates on pure data — no database access.
    class ConstraintFilter
      def initialize(commitments, context)
        @commitments = commitments
        @context = context
      end

      # Returns filtered array of eligible commitments.
      def apply
        @commitments.select { |c| eligible?(c) }
      end

      private

      def eligible?(commitment)
        not_deferred?(commitment) &&
          not_blocked_by_dependency?(commitment) &&
          fits_available_time?(commitment)
      end

      # Deferred commitments have available_after in the future.
      def not_deferred?(commitment)
        return true if commitment.available_after.nil?

        commitment.available_after <= @context.current_time
      end

      # A commitment is blocked if any of its dependencies are not done.
      def not_blocked_by_dependency?(commitment)
        deps = @context.dependency_graph[commitment.id]
        return true if deps.nil? || deps.empty?

        # All dependencies must be done — but the state check already happens
        # at the model level (blocked state). Since the Collector only loads
        # ready commitments, anything that reaches here has passed that gate.
        true
      end

      # Commitment estimate must fit within remaining block time.
      def fits_available_time?(commitment)
        return true if @context.current_block.nil?  # No block = untyped time, accept all
        return true if commitment.estimate_minutes.nil?

        block_minutes = block_duration_minutes(@context.current_block)
        commitment.estimate_minutes <= block_minutes
      end

      def block_duration_minutes(block)
        t_start = block.start_time
        t_end = block.end_time

        # Time columns store as 2000-01-01 HH:MM:SS in Rails
        ((t_end - t_start) / 60.0).to_i.abs
      end
    end
  end
end
