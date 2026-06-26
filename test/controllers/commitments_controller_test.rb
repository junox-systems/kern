require "test_helper"

class CommitmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commitment = commitments(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get commitments_url
    assert_response :success
  end

  test "should get new" do
    get new_commitment_url
    assert_response :success
  end

  test "should create commitment" do
    assert_difference("Commitment.count") do
      post commitments_url, params: { commitment: { available_after: @commitment.available_after, capability: @commitment.capability, category_id: @commitment.category_id, context: @commitment.context, description: @commitment.description, due_at: @commitment.due_at, estimate_minutes: @commitment.estimate_minutes, state: @commitment.state, title: @commitment.title, user_id: @commitment.user_id } }
    end

    assert_redirected_to commitment_url(Commitment.order(:created_at).last)
  end

  test "should show commitment" do
    get commitment_url(@commitment)
    assert_response :success
  end

  test "should get edit" do
    get edit_commitment_url(@commitment)
    assert_response :success
  end

  test "should update commitment" do
    patch commitment_url(@commitment), params: { commitment: { available_after: @commitment.available_after, capability: @commitment.capability, category_id: @commitment.category_id, context: @commitment.context, description: @commitment.description, due_at: @commitment.due_at, estimate_minutes: @commitment.estimate_minutes, state: @commitment.state, title: @commitment.title, user_id: @commitment.user_id } }
    assert_redirected_to commitment_url(@commitment)
  end

  test "should destroy commitment" do
    assert_difference("Commitment.count", -1) do
      delete commitment_url(@commitment)
    end

    assert_redirected_to commitments_url
  end
end
