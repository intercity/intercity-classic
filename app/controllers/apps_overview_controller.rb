class AppsOverviewController < ApplicationController
  before_action :authenticate_user!

  def index
    unless feature_flipper[:app_overview].enabled? current_user
      redirect_to servers_path
      return
    end
    @applications = current_user.applications.active_server
  end
end
