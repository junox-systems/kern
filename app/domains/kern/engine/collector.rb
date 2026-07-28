# frozen_string_literal: true

module Kern
  module Engine
    # Gathers all inputs for a scheduling run from the database
    # and assembles them into an immutable SchedulingContext.
    class Collector
      def initialize(operator, current_time: Time.current)
        @operator = operator
        @current_time = current_time
      end

      def gather
        blocks = todays_blocks
        current_block = find_current_block(blocks)

        SchedulingContext.new(
          categories: @operator.categories.to_a,
          commitments: eligible_commitments,
          calendar_blocks: blocks,
          current_block: current_block,
          attention_debt: AttentionDebtCalculator.new(@operator, @current_time).compute,
          dependency_graph: build_dependency_graph,
          current_time: @current_time
        )
      end

      private

      def eligible_commitments
        @operator.commitments.ready.to_a
      end

      def todays_blocks
        today = @current_time.to_date
        @operator.calendar_blocks.where(date: today).order(:start_time).to_a
      end

      def find_current_block(blocks)
        time_of_day = @current_time.strftime("%H:%M:%S")
        blocks.find do |block|
          block.start_time.strftime("%H:%M:%S") <= time_of_day &&
            time_of_day < block.end_time.strftime("%H:%M:%S")
        end
      end

      def build_dependency_graph
        deps = CommitmentDependency
          .joins(:commitment)
          .where(commitments: { user_id: @operator.id })
          .pluck(:commitment_id, :depends_on_id)

        deps.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(cid, did), graph|
          graph[cid] << did
        end
      end
    end
  end
end
