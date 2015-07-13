class EnvVarsController < ApplicationController
  layout "servers"
  before_action :authenticate_user!
  before_action :set_env_vars, only: [:index, :create]

  def index
    set_env_vars
    @env_var = EnvVar.new(application: current_app)
  end

  def create
    set_env_vars
    @env_var = current_app.env_vars.new(env_var_params)
    if !@env_var.save
      render :index
    else
      redirect_to env_vars_path(current_app.server, current_app)
    end
  end

  def destroy
    @env_var = current_app.env_vars.find(params[:id])
    unless @env_var.destroy
      flash[:error] = "Could not destroy environment variable"
    end
    redirect_to env_vars_path(current_app.server, current_app)
  end

  def apply
    if !current_app.server.working?
      if current_app.save
        current_app.server.update_attribute(:working, true)
        current_app.server.update_attribute(:last_error, nil)
        ApplyServerWorker.perform_async(current_app.server.id)
      end
      redirect_to env_vars_path(current_app.server, current_app)
    else
      redirect_to env_vars_path(current_app.server, current_app)
    end
  end

  private

  def set_env_vars
    @env_vars = current_app.env_vars
  end

  def env_var_params
    params.require(:env_var).permit(:key, :value)
  end
end
