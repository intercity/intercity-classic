class BackupsController < ApplicationController
  before_action :authenticate_user!

  layout :determine_layout

  def index
    backup
  end

  def overview
  end

  def fetch
    @data = BackupFetchService.new(current_user.applications_with_backups).execute
    respond_to :js
  end

  def update
    if !current_app.server.working?
      if backup.update(backup_params)
        current_app.server.update_attribute(:working, true)
        current_app.server.update_attribute(:last_error, nil)
        ApplyBackupsWorker.perform_async(current_app.server.id)
        redirect_to app_backups_path(current_app.server, current_app)
      else
        render :index
      end
    else
      render :index
    end
  end

  def force_backup
    flash[:success] = "The backup has been triggered! The archive should appear in your storage soon!"
    ForceBackupsWorker.perform_async(current_app.id)
    redirect_to app_backups_path(current_app.server, current_app)
  end

  private

  def backup
    @backup ||= current_app.backup
  end

  def backup_params
    params.require(:backup).permit(:enabled, :storage_type, :dropbox_api_key,
                                   :s3_access_key, :s3_secret_access_key,
                                   :s3_bucket, :s3_region, :dropbox_api_secret)
  end

  def determine_layout
    if action_name == "overview"
      "application"
    else
      "servers"
    end
  end
end
