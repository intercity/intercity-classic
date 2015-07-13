class AccountsController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "Your settings has been saved"
    else
      flash[:error] = "Not all fields where filled in correctly"
    end
    redirect_to account_path
  end

  private

  def user_params
    params.require(:user).permit(:digitalocean_access_token)
  end
end
