# frozen_string_literal: true

module Kern
  module Engine
    # Enforces the explainability contract.
    # Every recommendation must produce exactly three plain-language reasons:
    #   1. Category reason — why this category deserves attention now
    #   2. Time reason — why this block is suitable
    #   3. Commitment reason — why this specific commitment
    #
    # If any reason cannot be generated, the recommendation is not emitted.
    class ExplanationBuilder
      def initialize(candidate, context)
        @candidate = candidate
        @commitment = candidate[:commitment]
        @signals = candidate[:signals]
        @context = context
      end

      # Returns a Recommendation or nil if the contract cannot be satisfied.
      def build
        reasons = [
          category_reason,
          time_reason,
          commitment_reason
        ].compact

        # Explainability contract: all three reasons required.
        return nil if reasons.length < 3

        Recommendation.new(
          commitment: @commitment,
          rank: @candidate[:rank],
          reasons: reasons,
          score: @candidate[:score],
          generated_at: @context.current_time
        )
      end

      # Class-level convenience for pipeline usage.
      def self.build(candidate, context)
        new(candidate, context).build
      end

      private

      def category_reason
        debt_info = @signals[:category_debt]
        category = @commitment.category

        if category.nil?
          "Uncategorized commitment"
        elsif debt_info.nil? || debt_info[:debt] <= 0
          "#{category.name} allocation is on track this week"
        else
          hours = (debt_info[:debt] / 60.0).round(1)
          "#{category.name} is #{format_duration(debt_info[:debt])} under target this week"
        end
      end

      def time_reason
        block = @context.current_block

        if block.nil?
          "Open time available now"
        elsif block.capability.present?
          block_minutes = ((block.end_time - block.start_time) / 60.0).to_i.abs
          "#{format_duration(block_minutes)} #{block.capability} block available now"
        else
          block_minutes = ((block.end_time - block.start_time) / 60.0).to_i.abs
          "#{format_duration(block_minutes)} block available now"
        end
      end

      def commitment_reason
        hours = @signals[:hours_until_due]

        if hours.nil?
          "Ready to work on"
        elsif hours <= 0
          "Overdue"
        elsif hours <= 24
          "Due today"
        elsif hours <= 48
          "Due tomorrow"
        elsif hours <= 168
          days = (hours / 24.0).ceil
          "Due in #{days} days"
        else
          "Due #{@commitment.due_at.strftime('%b %-d')}"
        end
      end

      def format_duration(minutes)
        if minutes >= 60
          hours = (minutes / 60.0).round(1)
          hours == hours.to_i ? "#{hours.to_i}h" : "#{hours}h"
        else
          "#{minutes}min"
        end
      end
    end
  end
end
