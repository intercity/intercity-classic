class ApplicationsController < ApplicationController
  before_action :authenticate_user!
  layout "servers"

  def new
    @app = Application.new(ruby_version: "2.2.2")
  end

  def index
    @apps = current_server.applications
  end

  def create
    @app = Application.new(application_params.merge!(server: current_server))

    if current_server.working?
      @app.errors.add(:base, t("server.busy"))
    elsif @app.save
      apply_server(@app)
      redirect_to applying_application_url(current_server, @app)
      return
    end
    render :new
  end

  def show
    respond_to :html
  end

  def deploy
    render "deploy_#{current_server.stack}"
  end

  def edit
    respond_to :html
  end

  def update
    if current_server.working?
      current_app.errors.add(:base, t("server.busy"))
    elsif current_app.update_attributes(application_params)
      flash[:success] = "Changes have been saved. We're applying them to your server"
      apply_server(current_app)
      redirect_to edit_application_path(current_server, current_app)
      return
    end
    render :edit
  end

  def destroy
    current_app.mark_as_deleting
    current_server.update(working: true, last_error: nil)
    RemoveAppJob.perform_later current_app.id
    redirect_to server_path(current_server)
  end

  def applying
    respond_to :html
  end

  private

  def application_params
    params.require(:application).permit(:name, :enable_ssl, :domain_names, :database_user,
                                        :database_password, :rails_environment,
                                        :ruby_version, :database_name, :database_host,
                                        :deploy_user, :redirect_domain_names,
                                        :client_max_body_size)
  end

  def apply_server(application)
    server = application.server
    server.update(working: true, last_error: nil)
    ApplyServerWorker.perform_async(server.id)
  end
end
