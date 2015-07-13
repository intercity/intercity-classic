require 'test_helper'

class ApplicationDatabasesControllerTest < ActionController::TestCase
  test "should get show" do
    sign_in users(:michiel)

    application = applications(:intercity_beta)
    get :show, app_id: application, server_id: application.server

    assert_response :success
  end

  test "should put update" do
    sign_in users(:michiel)
    application = applications(:intercity_beta)
    connect_to_application = applications(:chef_builder_app1)
    connect_to_application.server = application.server
    connect_to_application.save!

    put :update, app_id: application, server_id: application.server,
      application: { use_database_from_other_application: "1",
                     connect_to_database_from_application_id: connect_to_application }

    assert_equal 1, ApplyServerWorker.jobs.size, "Expected job to be created"
    assert_redirected_to database_url(application.server, application)

    application.reload
    assert application.use_database_from_other_application?
  end
end
