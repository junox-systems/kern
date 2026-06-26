require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect show to login if unauthenticated" do
    get profile_url
    assert_redirected_to new_session_url
  end

  test "should show profile if authenticated" do
    sign_in_as(@user)
    get profile_url
    assert_response :success
  end

  test "should update profile basic fields" do
    sign_in_as(@user)
    patch profile_url, params: { user: { name: "Updated Name", email_address: "updated@example.com", timezone: "America/New_York" } }
    assert_redirected_to profile_url
    assert_equal "Profile updated successfully.", flash[:notice]

    @user.reload
    assert_equal "Updated Name", @user.name
    assert_equal "updated@example.com", @user.email_address
    assert_equal "America/New_York", @user.timezone
  end

  test "should update profile password when password parameters are supplied" do
    sign_in_as(@user)
    assert_changes -> { @user.reload.password_digest } do
      patch profile_url, params: { user: { name: @user.name, email_address: @user.email_address, timezone: @user.timezone, password: "newpassword", password_confirmation: "newpassword" } }
    end
    assert_redirected_to profile_url
  end

  test "should not update password when password parameters are blank" do
    sign_in_as(@user)
    assert_no_changes -> { @user.reload.password_digest } do
      patch profile_url, params: { user: { name: @user.name, email_address: @user.email_address, timezone: @user.timezone, password: "", password_confirmation: "" } }
    end
    assert_redirected_to profile_url
  end
end
