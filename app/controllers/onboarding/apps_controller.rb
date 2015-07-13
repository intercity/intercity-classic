class Onboarding::AppsController < Onboarding::BaseController
  skip_before_action :check_and_redirect_to_correct_step, only: :start
  def start
    session[:onboarding] = nil
    redirect_to setup_app_path
  end

  def new
    @onboarding = fetch_onboarding
  end

  def create
    @onboarding = fetch_onboarding
    @onboarding.validation_step = :new_app

    if @onboarding.update(onboarding_params.merge!(user: current_user))
      @onboarding.generate_rsa_key!
      @onboarding.update(last_finished_step: "app")
      session[:onboarding] = @onboarding.id
      redirect_to setup_provider_path
    else
      flash.now[:error] = "Oops! Looks like the information is not correct."
      render :new
    end
  end

  private

  def onboarding_params
    params.require(:onboarding).permit(:name, :ruby_version, :db_type)
  end
end
