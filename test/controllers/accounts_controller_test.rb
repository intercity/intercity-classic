require "test_helper"

class AccountsControllerTest < ActionController::TestCase
  test "Should redirect to login when not logged in" do
    get :show
    assert_response :redirect
  end
  test "should get show" do
    sign_in users(:michiel)
    get :show
    assert_response :success
  end

  test "Update should save do access_token" do
    sign_in users(:michiel)
    assert_nil users(:michiel).digitalocean_access_token
    patch :update, user: {digitalocean_access_token: "abc123"}
    refute_nil users(:michiel).reload.digitalocean_access_token
  end
end
