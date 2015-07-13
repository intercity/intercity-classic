class TrialController < ApplicationController
  before_action :signup_allowed?

  skip_before_action :verify_authenticity_token, only: [:signup, :availability]
  skip_before_action :authorize_user!

  def signup
    user = User.new(full_name: params[:full_name], email: params[:email], password: params[:password])

    if user.save
      sign_in user
      redirect_to dashboard_url
    else
      redirect_to :back
    end
  end

  def availability
    user = User.new(full_name: params[:full_name], email: params[:email], password: params[:password])
    user.valid?
    json_response = {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      errors: user.errors
    }
    render text: "#{params[:callback]}(#{json_response.to_json})", content_type: "text/javascript"
  end

  private

  def signup_allowed?
    redirect_to root_path unless Settings.intercity.signup_enabled
  end
end
