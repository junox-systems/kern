# frozen_string_literal: true

module Kern
  module Engine
    # Scores commitments based on attention debt, urgency, and fit.
    # Pure function — no database access.
    #
    # Returns an array of { commitment:, score:, signals: } hashes,
    # where signals preserve the individual scoring components for explainability.
    class Scorer
      # Weights for scoring signals — attention debt is primary.
      DEBT_WEIGHT    = 0.5
      URGENCY_WEIGHT = 0.35
      FIT_WEIGHT     = 0.15

      def initialize(commitments, attention_debt, current_time: Time.current)
        @commitments = commitments
        @attention_debt = attention_debt
        @current_time = current_time
      end

      def apply
        return [] if @commitments.empty?

        max_debt = @attention_debt.values.map { |d| d[:debt] }.max || 1
        max_debt = 1 if max_debt.zero?

        @commitments.map do |commitment|
          signals = compute_signals(commitment, max_debt)
          score = signals[:debt_score]    * DEBT_WEIGHT +
                  signals[:urgency_score] * URGENCY_WEIGHT +
                  signals[:fit_score]     * FIT_WEIGHT

          { commitment: commitment, score: score, signals: signals }
        end
      end

      private

      def compute_signals(commitment, max_debt)
        {
          debt_score: debt_signal(commitment, max_debt),
          urgency_score: urgency_signal(commitment),
          fit_score: fit_signal(commitment),
          # Raw values preserved for explanation generation
          category_debt: category_debt_for(commitment),
          hours_until_due: hours_until_due(commitment)
        }
      end

      # Categories with higher debt receive higher scores (0.0 to 1.0).
      def debt_signal(commitment, max_debt)
        debt_info = category_debt_for(commitment)
        return 0.0 unless debt_info

        debt_info[:debt].to_f / max_debt
      end

      # Commitments due sooner score higher (0.0 to 1.0).
      # No due date = 0.0 urgency (neutral, not penalized).
      def urgency_signal(commitment)
        return 0.0 if commitment.due_at.nil?

        hours_remaining = hours_until_due(commitment)

        if hours_remaining <= 0
          1.0  # Overdue = maximum urgency
        elsif hours_remaining <= 24
          0.9
        elsif hours_remaining <= 48
          0.7
        elsif hours_remaining <= 168  # 1 week
          0.4
        else
          0.1
        end
      end

      # How well does this commitment's estimated duration fit the current block?
      # Perfect fit = 1.0, much smaller or larger = lower score.
      def fit_signal(commitment)
        return 0.5 if commitment.estimate_minutes.nil?

        # Without a current block, we can't assess fit — neutral score.
        0.5
      end

      def category_debt_for(commitment)
        @attention_debt[commitment.category_id]
      end

      def hours_until_due(commitment)
        return nil if commitment.due_at.nil?

        ((commitment.due_at - @current_time) / 1.hour).to_f
      end
    end
  end
end
