# frozen_string_literal: true

module Kern
  module Engine
    # The Kernel — Kern's decision engine.
    #
    # A pure-function pipeline that takes operator state and produces
    # explainable attention recommendations.
    #
    # Pipeline stages:
    #   Collector        → gather all inputs from the database
    #   ConstraintFilter → remove ineligible commitments
    #   CapabilityFilter → match attention type to block type
    #   Scorer           → score by debt, urgency, and fit
    #   Ranker           → assign primary/secondary/hidden tiers
    #   ExplanationBuilder → generate three plain-language reasons
    #
    # The Collector is the only stage that touches the database.
    # Everything downstream operates on pure data.
    class Pipeline
      def self.run(operator:, current_time: Time.current)
        new(operator, current_time).run
      end

      def initialize(operator, current_time)
        @operator = operator
        @current_time = current_time
      end

      def run
        # 1. Collect — the only database-touching stage
        context = Collector.new(@operator, current_time: @current_time).gather

        # 2. Filter — remove ineligible commitments
        candidates = ConstraintFilter.new(context.commitments, context).apply

        # 3. Capability match — match attention type to block type
        candidates = CapabilityFilter.new(candidates, context.current_block).apply

        # 4. Score — attention debt, urgency, fit
        scored = Scorer.new(candidates, context.attention_debt, current_time: @current_time).apply

        # 5. Rank — assign tiers
        ranked = Ranker.new(scored).apply

        # 6. Explain — generate three reasons per recommendation
        recommendations = ranked.filter_map do |candidate|
          ExplanationBuilder.build(candidate, context)
        end

        recommendations
      end
    end
  end
end
