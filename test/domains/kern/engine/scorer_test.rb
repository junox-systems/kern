# frozen_string_literal: true

require "test_helper"

class Kern::Engine::ScorerTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @category = categories(:one)
    @now = Time.current
  end

  test "commitment with higher category debt scores higher" do
    c1 = build_commitment(category_id: "cat-a")
    c2 = build_commitment(category_id: "cat-b")

    debt = {
      "cat-a" => { allocated: 420, actual: 60, debt: 360 },
      "cat-b" => { allocated: 420, actual: 300, debt: 120 }
    }

    scored = Kern::Engine::Scorer.new([ c1, c2 ], debt, current_time: @now).apply

    score_a = scored.find { |s| s[:commitment] == c1 }[:score]
    score_b = scored.find { |s| s[:commitment] == c2 }[:score]

    assert score_a > score_b, "Higher-debt category should score higher"
  end

  test "overdue commitment scores higher urgency than distant due date" do
    c_overdue = build_commitment(due_at: 1.hour.ago)
    c_distant = build_commitment(due_at: 2.weeks.from_now)

    debt = { @category.id => { allocated: 420, actual: 0, debt: 420 } }

    scored = Kern::Engine::Scorer.new([ c_overdue, c_distant ], debt, current_time: @now).apply

    score_overdue = scored.find { |s| s[:commitment] == c_overdue }[:score]
    score_distant = scored.find { |s| s[:commitment] == c_distant }[:score]

    assert score_overdue > score_distant, "Overdue should score higher"
  end

  test "commitment with no due date gets zero urgency" do
    commitment = build_commitment(due_at: nil)
    debt = { @category.id => { allocated: 420, actual: 0, debt: 420 } }

    scored = Kern::Engine::Scorer.new([ commitment ], debt, current_time: @now).apply

    signals = scored.first[:signals]
    assert_equal 0.0, signals[:urgency_score]
  end

  test "returns empty array for empty input" do
    scored = Kern::Engine::Scorer.new([], {}, current_time: @now).apply
    assert_empty scored
  end

  private

  def build_commitment(category_id: nil, due_at: 2.days.from_now)
    Commitment.new(
      user: @user,
      category_id: category_id || @category.id,
      title: "Test",
      state: :ready,
      estimate_minutes: 60,
      due_at: due_at
    )
  end
end
