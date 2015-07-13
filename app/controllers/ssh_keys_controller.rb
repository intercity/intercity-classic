class SshKeysController < ApplicationController
  before_action :authenticate_user!

  layout "servers"

  def index
  end

  def new
    @ssh_key = SshKey.new
  end

  def create
    @ssh_key = current_server.ssh_keys.new(ssh_key_attributes)

    if @ssh_key.save
      current_server.update_attribute(:working, true)
      current_server.update_attribute(:last_error, nil)
      ApplySshKeysWorker.perform_async(current_server.id)
      redirect_to ssh_keys_url(current_server)
    else
      render :new
    end
  end

  def destroy
    @ssh_key = current_server.ssh_keys.find(params[:id])

    if @ssh_key.destroy
      current_server.update_attribute(:working, true)
      current_server.update_attribute(:last_error, nil)
      ApplySshKeysWorker.perform_async(current_server.id)
    end

    redirect_to ssh_keys_url(current_server)
  end

  private

  def ssh_key_attributes
    params.require(:ssh_key).permit(:name, :key)
  end
end
