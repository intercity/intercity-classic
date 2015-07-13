require "test_helper"

class BackupsControllerTest < ActionController::TestCase
  setup do
    @application = applications(:intercity_beta)
    @server = @application.server
    sign_in @server.owner
  end

  test "Index should be successfull" do
    get :index, server_id: @server, app_id: @application
    assert_equal backups(:disabled), assigns(:backup)
    assert_response :success
  end

  test "Update should update the settings for the backup" do
    patch :update, server_id: @server, app_id: @application, backup: {
      enabled: true, s3_access_key: "api", s3_secret_access_key: "secret"
    }
    assert_equal true, backups(:disabled).reload.enabled?
    assert_equal "api", backups(:disabled).reload.s3_access_key
    assert_equal "secret", backups(:disabled).reload.s3_secret_access_key

    assert_response :redirect
    assert_redirected_to app_backups_path(@server, @application)
  end
end
