class ServersController < ApplicationController
  before_action :authenticate_user!

  layout "application", only: [:new, :create, :index, :error, :bootstrapping, :upgrade_plan]

  def index
    @servers = current_user.servers.not_archived.includes(:applications)
  end

  def new
    @server = Server.new
  end

  def log
    @server = current_user.servers.find(params[:server_id])
    @log = ServerLog.new(@server).latest
    render layout: false unless @server.bootstrapped?
  end

  def setup
    @server = current_user.servers.find(params[:server_id])

    render :new
  end

  def show
    @server = current_user.servers.includes(:applications).find(params[:server_id])
    @applications = @server.applications

    if @server.working && !@server.bootstrapped?
      redirect_to bootstrapping_server_path(@server)
    elsif !@server.bootstrapped?
      if @server.last_error.nil?
        render :new, layout: "application"
      else
        redirect_to error_server_path(@server)
      end
    else
      redirect_to applications_url(@server)
    end
  end

  def bootstrap
    @server = current_user.servers.find(params[:server_id])

    unless @server.working?
      @server.update_attributes(server_params)
      @server.update_attribute(:working, true)
      @server.update_attribute(:last_error, nil)
      BootstrapServerWorker.perform_async(@server.id, params[:username], params[:password])
    end

    render :bootstrapping
  end

  def bootstrapping
    @server = current_user.servers.find(params[:server_id])
    if @server.bootstrapped?
      redirect_to server_path(@server)
      # render :bootstrapping
    else
      render :bootstrapping
    end
  end

  def check_bootstrap_status
    @server = current_user.servers.find(params[:server_id])
  end

  def create
    @server = Server.new(server_params)
    @server.owner = current_user
    @server.working = true
    @server.last_error = nil
    @server.stack = "passenger"
    if @server.digitalocean?
      @server.address = "0.0.0.0"
      @server.ssh_port = "22"
    end

    if @server.save
      if @server.digitalocean?
        BootstrapDigitaloceanWorker.perform_async(@server.id)
      else
        BootstrapServerWorker.perform_async(@server.id, params[:username], params[:password])
      end
      redirect_to server_url(@server)
    else
      render action: :new
    end
  end

  def edit
    @server = current_user.servers.find(params[:server_id])
  end

  def update
    @server = current_user.servers.find(params[:server_id])

    if @server.update_attributes(server_params.merge(working: true))
      ApplyServerWorker.perform_async(@server.id)
      redirect_to edit_server_url(@server), notice: "Changes saved."
    else
      render :edit
    end
  end

  def destroy
    @server = current_user.servers.find(params[:server_id])

    @server.archived = true
    if @server.save
      redirect_to dashboard_url, notice: "Server #{@server.name} has been removed from your account."
    else
      redirect_to remove_server_url(@server), alert: "Cannot remove this server from your account."
    end
  end

  def remove
    @server = current_user.servers.find(params[:server_id])
  end

  def error
    @server = current_user.servers.find(params[:server_id])
  end

  def poll
    if params[:include_deleted]
      @deleted_apps = current_server.applications.only_deleted
    end
    respond_to :js
  end

  private

  def server_params
    params.require(:server).permit(:name, :provider, :digitalocean_region,
                                   :address, :ssh_port, :ssh_deploy_keys, :db_type,
                                   :unattended_upgrades)
  end
end
