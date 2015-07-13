require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  setup do
    @subscriber = users :subscriber
  end

  test "should get new" do
    sign_in users(:subscriber)
    get :new
    assert_response :success
  end

  test "GET show should redirect to applications_path" do
    sign_in users(:michiel)
    get :show, server_id: servers(:bootstrapped)
    assert_response :redirect
    assert_redirected_to applications_path(servers(:bootstrapped))
  end

  test "should post create" do
    sign_in users(:subscriber)

    assert_difference 'Server.count' do
      post :create, server: { name: 'Intercity', address: 'localhost' }
    end
    assert_redirected_to server_url(assigns(:server))
  end

  test "should put update" do
    sign_in users(:michiel)
    post :update, server_id: servers(:new), server: { name: "new server name" }
    assert_redirected_to edit_server_url(assigns(:server))
  end

  test "should delete destroy" do
    sign_in users(:michiel)

    assert_difference "Server.archived.count" do
      delete :destroy, server_id: servers(:new), format: :js
    end
  end

  test "should get index" do
    sign_in users(:michiel)

    get :index
    assert_response :success

    servers(:new).update_attribute(:archived, true)

    get :index
    assert_response :success
    assert !assigns(:servers).include?(servers(:new)), "Expected @servers not to include archived servers(:new)"
  end

  test "should get index with non-onboarded server" do
    user = users(:michiel)
    sign_in users(:michiel)

    user.servers.create!(name: "my server", address: "1.2.3.4", wizard_finished: nil, onboarding: nil)

    get :index
    assert_response :success
  end
end
