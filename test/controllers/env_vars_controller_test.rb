require "test_helper"

class EnvVarsControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:michiel)
    get :index, server_id: servers(:bootstrapped),
                app_id: applications(:intercity_beta)
    assert_includes assigns(:env_vars), env_vars(:secret_key)
    assert_response :success
  end

  test "POST create adds an ENV var" do
    sign_in users(:michiel)
    assert_difference "applications(:intercity_beta).env_vars.count" do
      post :create, server_id: servers(:bootstrapped),
                    app_id: applications(:intercity_beta),
                    env_var: { key: "super_key", value: "super_value" }
    end
    assert_response :redirect
  end

  test "DELETE destroy env_var removes the ENV var" do
    sign_in users(:michiel)
    assert_difference "applications(:intercity_beta).env_vars.count", -1 do
      delete :destroy, server_id: servers(:bootstrapped),
                       app_id: applications(:intercity_beta),
                       id: env_vars(:secret_key)
    end
    assert_response :redirect
  end
end
