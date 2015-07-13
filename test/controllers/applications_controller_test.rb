require 'test_helper'

class ApplicationsControllerTest < ActionController::TestCase
  setup do
    @app = applications(:intercity_beta)
    @server = @app.server
  end

  test "should get new" do
    sign_in users(:michiel)

    get :new, server_id: servers(:new)
    assert_response :success
  end

  test "should post create" do
    sign_in users(:michiel)

    assert_difference "Application.count" do
      post :create, server_id: servers(:bootstrapped),
                    application: { name: "intercity_staging",
                                   domain_names: "beta.intercityup.nl" }
    end

    assert_redirected_to applying_application_url(servers(:bootstrapped),
                                                  Application.last)


  end

  test "should patch update" do
    sign_in users(:michiel)

    patch :update, app_id: applications(:intercity_beta),
      server_id: servers(:bootstrapped),
      application: { name: "new_name", rails_environment: "staging" }

    assert_equal "staging", applications(:intercity_beta).reload.rails_environment
    assert_redirected_to edit_application_url(servers(:bootstrapped),
                                              applications(:intercity_beta))
  end

  test "should get edit" do
    sign_in users(:michiel)

    get :edit, app_id: applications(:intercity_beta),
               server_id: servers(:bootstrapped)

    assert_response :success
  end

  test "DELETE destroy should remove the app and redirect back to server page" do
    sign_in users(:michiel)
    RemoveAppJob.expects(:perform_later)
    delete :destroy, app_id: @app, server_id: @server
    assert @app.reload.deleting?, "App should be marked as deleting"
    assert_response :redirect
    assert_redirected_to server_path(@server)
  end
end
