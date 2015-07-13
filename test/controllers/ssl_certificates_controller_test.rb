require "test_helper"
class SslCertificatesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:michiel)
    @server = servers(:bootstrapped)
    @app = applications(:intercity_beta)
  end

  test "GET new should be succesful" do
    get :new, server_id: servers(:bootstrapped),
              app_id: applications(:intercity_beta)
    assert_response :success
  end

  test "GET new redirects to SHOW when a certificate is installed" do
    app = applications(:intercity_beta)
    add_ssl_to(app)
    get :new, server_id: servers(:bootstrapped), app_id: app
    assert_response :redirect
  end

  test "POST create should save the certificate to the given app" do
    ApplyServerWorker.expects(:perform_async)
    post :create, server_id: servers(:bootstrapped),
                  app_id: applications(:intercity_beta),
                  application: {
                    cert: fixture_file_upload("files/certificate.crt"),
                    key: fixture_file_upload("files/certificate.key"),
                    enable_ssl: true
                  }
    assert_response :redirect
    app = applications(:intercity_beta).reload
    assert_equal File.read("test/fixtures/files/certificate.crt").chomp,
                 app.reload.ssl_cert
    assert_equal File.read("test/fixtures/files/certificate.key").chomp,
                 app.ssl_key
  end

  test "POST create with invalid SSL certificate should not save the app" do
    post :create, server_id: servers(:bootstrapped),
                  app_id: applications(:intercity_beta),
                  application: {
                    cert: fixture_file_upload("files/test.crt"),
                    key: fixture_file_upload("files/test.key"),
                    enable_ssl: true }
    assert_response :success
  end

  test "POST create with empty cert and key should not blow up" do
    post :create, server_id: servers(:bootstrapped),
                  app_id: applications(:intercity_beta),
                  application: {
                    enable_ssl: true
                  }
    assert_response :success
  end

  test "GET show should be successful" do
    add_ssl_to(@app)
    get :show, server_id: @server, app_id: @app
    assert_response :success
  end

  test "GET show should redirect to NEW when ssl is not enabled" do
    get :show, server_id: @server, app_id: @app
    assert_response :redirect
  end

  test "DELETE destroy should disable the SSL and remove the certificate" do
    add_ssl_to(@app)
    RemoveSslCertificateJob.expects(:perform_later)
    assert @app.enable_ssl?, "SSL Should be enabled"
    delete :destroy, server_id: @server, app_id: @app
    refute @app.reload.enable_ssl?, "SSL Should be disabled"
    assert @app.reload.ssl_cert.nil?, "SSL cert should be nil"
    assert @app.reload.ssl_key.nil?, "SSL key should be nil"
    assert_response :redirect
  end
end
