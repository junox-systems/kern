require "test_helper"

class CalendarBlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calendar_block = calendar_blocks(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get calendar_blocks_url
    assert_response :success
  end

  test "should get new" do
    get new_calendar_block_url
    assert_response :success
  end

  test "should create calendar_block" do
    assert_difference("CalendarBlock.count") do
      post calendar_blocks_url, params: { calendar_block: { block_schedule_id: @calendar_block.block_schedule_id, block_type: @calendar_block.block_type, calendar_id: @calendar_block.calendar_id, capability: @calendar_block.capability, category_id: @calendar_block.category_id, date: @calendar_block.date, end_time: @calendar_block.end_time, external_uid: "new-unique-external-uid", start_time: @calendar_block.start_time, user_id: @calendar_block.user_id } }
    end

    assert_redirected_to calendar_block_url(CalendarBlock.order(:created_at).last)
  end

  test "should show calendar_block" do
    get calendar_block_url(@calendar_block)
    assert_response :success
  end

  test "should get edit" do
    get edit_calendar_block_url(@calendar_block)
    assert_response :success
  end

  test "should update calendar_block" do
    patch calendar_block_url(@calendar_block), params: { calendar_block: { block_schedule_id: @calendar_block.block_schedule_id, block_type: @calendar_block.block_type, calendar_id: @calendar_block.calendar_id, capability: @calendar_block.capability, category_id: @calendar_block.category_id, date: @calendar_block.date, end_time: @calendar_block.end_time, external_uid: @calendar_block.external_uid, start_time: @calendar_block.start_time, user_id: @calendar_block.user_id } }
    assert_redirected_to calendar_block_url(@calendar_block)
  end

  test "should destroy calendar_block" do
    assert_difference("CalendarBlock.count", -1) do
      delete calendar_block_url(@calendar_block)
    end

    assert_redirected_to calendar_blocks_url
  end
end
