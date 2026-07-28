# frozen_string_literal: true

require "test_helper"

class Kern::Engine::CapabilityFilterTest < ActiveSupport::TestCase
  setup do
    @operator = operators(:one)
    @category = categories(:one)
  end

  test "commitment with matching capability passes" do
    commitment = build_commitment(capability: :deep)
    block = build_block(capability: :deep)

    result = Kern::Engine::CapabilityFilter.new([ commitment ], block).apply

    assert_equal [ commitment ], result
  end

  test "commitment with mismatching capability is excluded" do
    commitment = build_commitment(capability: :deep)
    block = build_block(capability: :light)

    result = Kern::Engine::CapabilityFilter.new([ commitment ], block).apply

    assert_empty result
  end

  test "commitment with no capability matches any block" do
    commitment = build_commitment(capability: nil)
    block = build_block(capability: :deep)

    result = Kern::Engine::CapabilityFilter.new([ commitment ], block).apply

    assert_equal [ commitment ], result
  end

  test "all commitments pass when no current block" do
    commitment = build_commitment(capability: :deep)

    result = Kern::Engine::CapabilityFilter.new([ commitment ], nil).apply

    assert_equal [ commitment ], result
  end

  test "all commitments pass when block has no capability" do
    commitment = build_commitment(capability: :deep)
    block = build_block(capability: nil)

    result = Kern::Engine::CapabilityFilter.new([ commitment ], block).apply

    assert_equal [ commitment ], result
  end

  private

  def build_commitment(capability:)
    Commitment.new(
      operator: @operator,
      category: @category,
      title: "Test",
      state: :ready,
      capability: capability,
      estimate_minutes: 60
    )
  end

  def build_block(capability:)
    CalendarBlock.new(
      operator: @operator,
      category: @category,
      capability: capability,
      date: Date.current,
      start_time: "10:00",
      end_time: "11:30"
    )
  end
end
