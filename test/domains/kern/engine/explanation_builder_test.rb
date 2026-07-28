# frozen_string_literal: true

require "test_helper"

class Kern::Engine::ExplanationBuilderTest < ActiveSupport::TestCase
  setup do
    @operator = operators(:one)
    @category = categories(:one)
    @now = Time.current
  end

  test "produces three reasons for a valid candidate" do
    commitment = build_commitment(due_at: 1.day.from_now)
    candidate = build_candidate(commitment)
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_not_nil recommendation
    assert_equal 3, recommendation.reasons.length
    assert recommendation.reasons.all? { |r| r.is_a?(String) && r.present? }
  end

  test "category reason mentions debt when category is under target" do
    commitment = build_commitment(due_at: 1.day.from_now)
    candidate = build_candidate(commitment, category_debt: { allocated: 420, actual: 60, debt: 360 })
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_match(/under target/, recommendation.reasons[0])
  end

  test "time reason mentions current block capability" do
    commitment = build_commitment(due_at: 1.day.from_now)
    candidate = build_candidate(commitment)
    block = build_block(capability: :deep)
    context = build_context(current_block: block)

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_match(/deep/, recommendation.reasons[1])
  end

  test "commitment reason says 'Due tomorrow' for commitment due in ~24 hours" do
    commitment = build_commitment(due_at: 30.hours.from_now)
    candidate = build_candidate(commitment, hours_until_due: 30.0)
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_match(/Due tomorrow/, recommendation.reasons[2])
  end

  test "commitment reason says 'Overdue' for past-due commitment" do
    commitment = build_commitment(due_at: 2.hours.ago)
    candidate = build_candidate(commitment, hours_until_due: -2.0)
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_match(/Overdue/, recommendation.reasons[2])
  end

  test "commitment reason says 'Ready to work on' when no due date" do
    commitment = build_commitment(due_at: nil)
    candidate = build_candidate(commitment, hours_until_due: nil)
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_match(/Ready to work on/, recommendation.reasons[2])
  end

  test "preserves rank from candidate" do
    commitment = build_commitment(due_at: 1.day.from_now)
    candidate = build_candidate(commitment).merge(rank: :secondary)
    context = build_context

    recommendation = Kern::Engine::ExplanationBuilder.build(candidate, context)

    assert_equal :secondary, recommendation.rank
  end

  private

  def build_commitment(due_at:)
    Commitment.new(
      operator: @operator,
      category: @category,
      title: "Write proposal",
      state: :ready,
      capability: :deep,
      estimate_minutes: 90,
      due_at: due_at
    )
  end

  def build_candidate(commitment, category_debt: nil, hours_until_due: 24.0)
    debt = category_debt || { allocated: 420, actual: 60, debt: 360 }
    {
      commitment: commitment,
      score: 0.85,
      rank: :primary,
      signals: {
        debt_score: 0.9,
        urgency_score: 0.7,
        fit_score: 0.5,
        category_debt: debt,
        hours_until_due: hours_until_due
      }
    }
  end

  def build_block(capability: :deep)
    CalendarBlock.new(
      operator: @operator,
      category: @category,
      capability: capability,
      date: Date.current,
      start_time: "10:00",
      end_time: "11:30"
    )
  end

  def build_context(current_block: nil)
    Kern::Engine::SchedulingContext.new(
      categories: [ @category ],
      commitments: [],
      calendar_blocks: current_block ? [ current_block ] : [],
      current_block: current_block,
      attention_debt: { @category.id => { allocated: 420, actual: 60, debt: 360 } },
      dependency_graph: {},
      current_time: @now
    )
  end
end
