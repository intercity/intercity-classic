class ApplicationDatabasesController < ApplicationController
  before_action :authenticate_user!

  layout "servers"

  def show
  end

  def update
    if !current_app.server.working?
      if current_app.update_attributes(application_database_params)
        current_app.server.update_attribute(:working, true)
        current_app.server.update_attribute(:last_error, nil)
        ApplyServerWorker.perform_async(current_app.server.id)
        redirect_to database_url(current_app.server, current_app)
      else
        render :show
      end
    else
      redirect_to database_url(current_app.server, current_app)
    end
  end

  private

  def application_database_params
    params.require(:application).permit(:use_database_from_other_application,
                                        :connect_to_database_from_application_id)
  end
end
