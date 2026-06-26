require "test_helper"

class BlockScheduleTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @calendar = calendars(:one)
    @category = categories(:one)
  end

  test "start time must be before end time" do
    schedule = BlockSchedule.new(
      user: @user,
      calendar: @calendar,
      category: @category,
      start_time: "10:00:00",
      end_time: "09:00:00",
      days_of_week: [1, 2]
    )
    assert_not schedule.valid?
    assert_includes schedule.errors[:end_time], "must be after start time"
  end

  test "effective_until must be after effective_from" do
    schedule = BlockSchedule.new(
      user: @user,
      calendar: @calendar,
      category: @category,
      start_time: "09:00:00",
      end_time: "10:00:00",
      days_of_week: [1, 2],
      effective_from: Date.tomorrow,
      effective_until: Date.yesterday
    )
    assert_not schedule.valid?
    assert_includes schedule.errors[:effective_until], "must be on or after effective_from"
  end

  test "validates days of week" do
    schedule = BlockSchedule.new(
      user: @user,
      calendar: @calendar,
      category: @category,
      start_time: "09:00:00",
      end_time: "10:00:00",
      days_of_week: [8]
    )
    assert_not schedule.valid?
    assert_includes schedule.errors[:days_of_week], "must be an array of integers 0-6"
  end
end
