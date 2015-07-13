class RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_params, if: :devise_controller?
  before_action :signup_allowed?

  def after_sign_up_path_for(_resource)
    root_path
  end

  private

  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:full_name, :email, :password)
    end
  end

  def signup_allowed?
    redirect_to root_path unless Settings.intercity.signup_enabled
  end
end
