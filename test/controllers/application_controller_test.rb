require "test_helper"
class TestableController < ApplicationController
  def show
    render :text => 'rendered content here', :status => 200
  end
end
Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  get 'show' => 'testable#show'
end

class ApplicationControllerTest < ActionController::TestCase
  tests TestableController

  setup do
    sign_in users(:michiel)
    @server = servers(:bootstrapped)
    @app = @server.applications.first
  end

  test "#current_server returns the current server if server_id is present" do
    get :show, server_id: @server.id
    assert_equal @server, @controller.current_server
    assert_response :ok
  end

  test "#current_app returns the current app is server_id and app_id is present" do
    get :show, server_id: @server.id, app_id: @app.id
    assert_equal @app, @controller.current_app
    assert_response :ok
  end
end

