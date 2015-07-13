class Onboarding::ServersController < Onboarding::BaseController
  skip_before_action :check_and_redirect_to_correct_step, only: :poll

  def create
    @onboarding = fetch_onboarding
    server_and_app = @onboarding.create_server_and_app
    current_user.update(digitalocean_access_token: @onboarding.digitalocean_api_key)
    OnboardingJob.perform_later(server_and_app[:server].id)
    @onboarding.update(last_finished_step: "installing")
    redirect_to setup_install_server_path(@onboarding, @onboarding.server)
  end

  def show
    @onboarding = fetch_onboarding
    session[:onboarding] = @onboarding.id
    render "progress_#{@onboarding.provider}"
  end

  def poll
    @onboarding = fetch_onboarding
  end
end
