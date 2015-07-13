class Onboarding::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :check_and_redirect_to_correct_step

  protected

  def check_and_redirect_to_correct_step
    return if request.post? || allowed_paths_for_current_step.include?(request.path)
    onboarding = fetch_onboarding
    redirection_path = case onboarding.last_finished_step
                       when "app"
                         setup_provider_path
                       when "provider_digitalocean"
                         setup_droplet_path
                       when "provider_custom_server"
                         setup_custom_server_path
                       when "installing"
                         setup_install_server_path(onboarding.id)
                       when "check_custom_server"
                         setup_custom_server_summary_path
                       else
                         setup_app_path
                       end
    redirect_to redirection_path unless request.path == redirection_path
  rescue ActiveRecord::RecordNotFound
    redirect_to setup_app_path unless request.path == setup_app_path
  end

  def allowed_paths_for_current_step
    onboarding = fetch_onboarding
    paths = [setup_app_path]
    case onboarding.last_finished_step
    when "app"
      paths << setup_provider_path
    when "provider_digitalocean"
      paths += [setup_provider_path, setup_droplet_path]
    when "provider_custom_server"
      paths += [setup_provider_path, setup_custom_server_path]
    when "installing"
      paths = [setup_install_server_path(onboarding.id)]
    end
    paths
  rescue ActiveRecord::RecordNotFound
    [setup_app_path]
  end

  def fetch_onboarding
    Onboarding.find_by!(id: params[:id] || session[:onboarding], user: current_user)
  rescue ActiveRecord::RecordNotFound
    Onboarding.new
  end
end
