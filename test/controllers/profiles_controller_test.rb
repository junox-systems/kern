require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @operator = operators(:one)
  end

  test "should redirect show to login if unauthenticated" do
    get profile_url
    assert_redirected_to new_session_url
  end

  test "should show profile if authenticated" do
    sign_in_as(@operator)
    get profile_url
    assert_response :success
  end

  test "should update profile basic fields" do
    sign_in_as(@operator)
    patch profile_url, params: { operator: { name: "Updated Name", email_address: "updated@example.com", timezone: "America/New_York" } }
    assert_redirected_to profile_url
    assert_equal "Profile updated successfully.", flash[:notice]

    @operator.reload
    assert_equal "Updated Name", @operator.name
    assert_equal "updated@example.com", @operator.email_address
    assert_equal "America/New_York", @operator.timezone
  end

  test "should update profile password when password parameters are supplied" do
    sign_in_as(@operator)
    assert_changes -> { @operator.reload.password_digest } do
      patch profile_url, params: { operator: { name: @operator.name, email_address: @operator.email_address, timezone: @operator.timezone, password: "newpassword", password_confirmation: "newpassword" } }
    end
    assert_redirected_to profile_url
  end

  test "should not update password when password parameters are blank" do
    sign_in_as(@operator)
    assert_no_changes -> { @operator.reload.password_digest } do
      patch profile_url, params: { operator: { name: @operator.name, email_address: @operator.email_address, timezone: @operator.timezone, password: "", password_confirmation: "" } }
    end
    assert_redirected_to profile_url
  end
end
