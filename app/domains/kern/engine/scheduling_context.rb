# frozen_string_literal: true

module Kern
  module Engine
    # Immutable context holding all inputs for a scheduling run.
    # The Kernel pipeline operates exclusively on this value object.
    SchedulingContext = Data.define(
      :categories,          # Array of category data (id, name, priority, weekly_allocation_minutes)
      :commitments,         # Array of ready commitments
      :calendar_blocks,     # Array of today's calendar blocks
      :current_block,       # The block covering current_time (or nil)
      :attention_debt,      # Hash { category_id => { allocated:, actual:, debt: } }
      :dependency_graph,    # Hash { commitment_id => [depends_on_ids] }
      :current_time         # Time
    )
  end
end
