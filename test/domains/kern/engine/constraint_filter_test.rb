# frozen_string_literal: true

require "test_helper"

class Kern::Engine::ConstraintFilterTest < ActiveSupport::TestCase
  setup do
    @operator = operators(:one)
    @category = categories(:one)
    @now = Time.current
  end

  test "ready commitment with no constraints passes" do
    commitment = build_commitment
    context = build_context(commitments: [ commitment ])

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_equal [ commitment ], result
  end

  test "deferred commitment with future available_after is excluded" do
    commitment = build_commitment(available_after: 2.days.from_now)
    context = build_context(commitments: [ commitment ])

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_empty result
  end

  test "deferred commitment with past available_after passes" do
    commitment = build_commitment(available_after: 1.day.ago)
    context = build_context(commitments: [ commitment ])

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_equal [ commitment ], result
  end

  test "commitment with nil available_after passes" do
    commitment = build_commitment(available_after: nil)
    context = build_context(commitments: [ commitment ])

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_equal [ commitment ], result
  end

  test "commitment larger than block is excluded" do
    commitment = build_commitment(estimate_minutes: 180)
    block = build_block(start_time: "10:00", end_time: "11:00") # 60 minutes
    context = build_context(commitments: [ commitment ], current_block: block)

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_empty result
  end

  test "commitment fitting block passes" do
    commitment = build_commitment(estimate_minutes: 45)
    block = build_block(start_time: "10:00", end_time: "11:00") # 60 minutes
    context = build_context(commitments: [ commitment ], current_block: block)

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_equal [ commitment ], result
  end

  test "commitment with no estimate passes" do
    commitment = build_commitment(estimate_minutes: nil)
    block = build_block(start_time: "10:00", end_time: "11:00")
    context = build_context(commitments: [ commitment ], current_block: block)

    result = Kern::Engine::ConstraintFilter.new([ commitment ], context).apply

    assert_equal [ commitment ], result
  end

  private

  def build_commitment(available_after: nil, estimate_minutes: 60)
    Commitment.new(
      operator: @operator,
      category: @category,
      title: "Test",
      state: :ready,
      estimate_minutes: estimate_minutes,
      available_after: available_after
    )
  end

  def build_block(start_time: "10:00", end_time: "11:30")
    CalendarBlock.new(
      operator: @operator,
      category: @category,
      date: Date.current,
      start_time: start_time,
      end_time: end_time
    )
  end

  def build_context(commitments: [], current_block: nil)
    Kern::Engine::SchedulingContext.new(
      categories: [ @category ],
      commitments: commitments,
      calendar_blocks: current_block ? [ current_block ] : [],
      current_block: current_block,
      attention_debt: {},
      dependency_graph: {},
      current_time: @now
    )
  end
end
