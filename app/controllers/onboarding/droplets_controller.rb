class Onboarding::DropletsController < Onboarding::BaseController
  def new
    @onboarding = fetch_onboarding
    @onboarding.digitalocean_api_key = current_user.digitalocean_access_token
  end

  def create
    @onboarding = fetch_onboarding
    @onboarding.validation_step = :new_droplet

    if @onboarding.update(onboarding_params)
      render :create
    else
      flash.now[:error] = "Oops! Looks like the information is not correct."
      render :new
    end
  end

  private

  def onboarding_params
    params.require(:onboarding).permit(:digitalocean_region, :digitalocean_api_key)
  end
end
