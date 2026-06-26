require "test_helper"

class CalendarBlockTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @calendar = calendars(:one)
    @category = categories(:one)
  end

  test "start time must be before end time" do
    block = CalendarBlock.new(
      user: @user,
      calendar: @calendar,
      category: @category,
      date: Date.today,
      start_time: "10:00:00",
      end_time: "09:00:00",
      external_uid: "test1"
    )
    assert_not block.valid?
    assert_includes block.errors[:end_time], "must be after start time"
  end

  test "requires date, start time, end time" do
    block = CalendarBlock.new(
      user: @user,
      calendar: @calendar,
      category: @category
    )
    assert_not block.valid?
    assert_includes block.errors[:date], "can't be blank"
    assert_includes block.errors[:start_time], "can't be blank"
    assert_includes block.errors[:end_time], "can't be blank"
  end
end
