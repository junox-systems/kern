# frozen_string_literal: true

module Kern
  module Engine
    # Ranks scored commitments and assigns recommendation tiers.
    # Pure function — no database access.
    class Ranker
      PRIMARY_COUNT   = 1
      SECONDARY_COUNT = 3

      def initialize(scored_candidates)
        @scored_candidates = scored_candidates
      end

      # Returns an array of { commitment:, rank:, score:, signals: } hashes,
      # sorted by score descending, with rank assigned.
      def apply
        sorted = @scored_candidates.sort_by { |c| -c[:score] }

        sorted.each_with_index.map do |candidate, index|
          rank = if index < PRIMARY_COUNT
                   :primary
                 elsif index < PRIMARY_COUNT + SECONDARY_COUNT
                   :secondary
                 else
                   :hidden
                 end

          candidate.merge(rank: rank)
        end
      end
    end
  end
end
