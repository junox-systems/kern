# frozen_string_literal: true

module Kern
  module Engine
    # Computes per-category attention debt for the current week.
    #
    # Attention debt = allocated_minutes - actual_minutes
    #
    # "Actual" is derived from operator events: when a commitment is completed,
    # its estimate_minutes count toward the category's actual time for that week.
    class AttentionDebtCalculator
      def initialize(operator, current_time)
        @operator = operator
        @current_time = current_time
      end

      # Returns Hash { category_id => { allocated:, actual:, debt: } }
      def compute
        actuals = compute_actuals
        categories = @operator.categories

        categories.each_with_object({}) do |category, debt|
          allocated = category.weekly_allocation_minutes || 0
          actual = actuals[category.id] || 0

          debt[category.id] = {
            allocated: allocated,
            actual: actual,
            debt: [ allocated - actual, 0 ].max
          }
        end
      end

      private

      # Sum estimate_minutes of commitments completed this week, grouped by category.
      def compute_actuals
        week_start = @current_time.beginning_of_week
        week_end = @current_time.end_of_week

        completed_events = OperatorEvent
          .where(user: @operator)
          .where(event_type: :complete)
          .where(created_at: week_start..week_end)
          .includes(commitment: :category)

        completed_events.each_with_object(Hash.new(0)) do |event, actuals|
          commitment = event.commitment
          next unless commitment&.category_id

          actuals[commitment.category_id] += (commitment.estimate_minutes || 0)
        end
      end
    end
  end
end
