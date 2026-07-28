# frozen_string_literal: true

module Kern
  module Engine
    # Output of the Kernel pipeline — an ephemeral recommendation.
    Recommendation = Data.define(
      :commitment,    # The commitment being recommended
      :rank,          # :primary, :secondary, or :hidden
      :reasons,       # Array of exactly 3 plain-language strings
      :score,         # Numeric score (for internal ranking)
      :generated_at   # Time of generation
    ) do
      def primary? = rank == :primary
      def secondary? = rank == :secondary
    end
  end
end
