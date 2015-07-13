class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if feature_flipper[:app_overview].enabled? current_user
      app_overview_flow
    else
      server_overview_flow
    end
  end

  def getting_started
    render layout: "login"
  end

  private

  def app_overview_flow
    @applications = current_user.applications.active_server

    if @applications.any?
      redirect_to app_overview_path
    else
      render "welcome"
    end
  end

  def server_overview_flow
    @servers = current_user.servers.not_archived
    if @servers.any?
      redirect_to servers_path
    else
      render "welcome"
    end
  end
end
