class Onboarding::ProvidersController < Onboarding::BaseController
  def new
    @onboarding = fetch_onboarding
  end

  def create
    @onboarding = fetch_onboarding
    if @onboarding.update(provider: params[:onboarding][:provider])
      if @onboarding.digitalocean?
        @onboarding.update(last_finished_step: "provider_digitalocean")
        redirect_to setup_droplet_path
      else
        @onboarding.update(last_finished_step: "provider_custom_server")
        redirect_to setup_custom_server_path
      end
    else
      redirect_to setup_provider_path
    end
  end
end
