# frozen_string_literal: true

require "test_helper"

class Kern::Engine::PipelineTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @category = categories(:one)
  end

  test "produces a recommendation for a ready commitment" do
    # Ensure we have a ready commitment
    commitment = @user.commitments.create!(
      title: "Write proposal",
      category: @category,
      state: :ready,
      capability: :light,
      estimate_minutes: 60,
      due_at: 1.day.from_now
    )

    # Create a calendar block for today with matching capability
    calendar = @user.calendars.first || @user.calendars.create!(name: "Default")
    calendar.calendar_blocks.create!(
      user: @user,
      category: @category,
      capability: :light,
      date: Date.current,
      start_time: "00:00",
      end_time: "23:59",
      block_type: :manual
    )

    recommendations = Kern::Engine::Pipeline.run(operator: @user, current_time: Time.current)

    assert recommendations.any?, "Pipeline should produce at least one recommendation"

    primary = recommendations.find(&:primary?)
    assert_not_nil primary, "Should have a primary recommendation"
    assert_equal 3, primary.reasons.length, "Explainability contract: 3 reasons required"
    assert primary.reasons.all? { |r| r.is_a?(String) && r.present? }
  end

  test "returns empty when no ready commitments exist" do
    @user.commitments.update_all(state: :done)

    recommendations = Kern::Engine::Pipeline.run(operator: @user, current_time: Time.current)

    assert_empty recommendations
  end

  test "excludes deferred commitments" do
    @user.commitments.ready.update_all(available_after: 3.days.from_now)

    recommendations = Kern::Engine::Pipeline.run(operator: @user, current_time: Time.current)

    assert_empty recommendations
  end

  test "commitment with wrong capability is excluded when block exists" do
    @user.commitments.ready.update_all(capability: :deep)

    calendar = @user.calendars.first || @user.calendars.create!(name: "Default")
    calendar.calendar_blocks.create!(
      user: @user,
      category: @category,
      capability: :physical,
      date: Date.current,
      start_time: "00:00",
      end_time: "23:59",
      block_type: :manual
    )

    recommendations = Kern::Engine::Pipeline.run(operator: @user, current_time: Time.current)

    # Deep commitments should not appear in a physical block
    assert recommendations.none? { |r| r.commitment.deep? }
  end

  test "pipeline is deterministic — same inputs produce same outputs" do
    commitment = @user.commitments.create!(
      title: "Determinism test",
      category: @category,
      state: :ready,
      estimate_minutes: 30,
      due_at: 2.days.from_now
    )

    frozen_time = Time.current

    r1 = Kern::Engine::Pipeline.run(operator: @user.reload, current_time: frozen_time)
    r2 = Kern::Engine::Pipeline.run(operator: @user.reload, current_time: frozen_time)

    assert_equal r1.length, r2.length
    assert_equal r1.map { |r| r.commitment.id }, r2.map { |r| r.commitment.id }
    assert_equal r1.map(&:score), r2.map(&:score)
  end
end
