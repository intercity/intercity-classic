class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :feature_flipper, :current_server, :current_app

  def feature_flipper
    @feature_flipper ||= FeatureFlipper.new
  end

  def user_subscribed?
    current_user.subscribed?
  end

  def current_plan
    current_user.plan
  end

  def current_server
    return unless params[:server_id]
    @current_server ||= current_user.servers.find(params[:server_id])
  end

  def current_app
    return unless params[:app_id]
    @current_app ||= current_server.applications.find(params[:app_id])
  end
end
