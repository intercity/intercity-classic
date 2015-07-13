require "digest"
class SslCertificatesController < ApplicationController
  layout "servers"
  def new
    if current_app.enable_ssl?
      redirect_to ssl_certificates_path(current_app.server, current_app)
    else
      render :new
    end
  end

  def create
    current_app.validate_ssl = true
    if current_app.update(ssl_cert: read_file(:cert), ssl_key: read_file(:key),
                          enable_ssl: true)
      apply_server
      redirect_to ssl_certificates_path(current_app.server, current_app)
    else
      render :new
    end
  end

  def show
    if current_app.enable_ssl?
      render :show
    else
      redirect_to new_ssl_certificates_path(current_app.server, current_app)
    end
  end

  def destroy
    if current_app.update!(ssl_cert: nil, ssl_key: nil, enable_ssl: false)
      apply_server
      flash[:succes] = "SSL is succesfully disabled"
    else
      flash[:error] = "We could not disable SSL, can you try again later?"
    end
    redirect_to ssl_certificates_path(current_app.server, current_app)
  end

  private

  def read_file(key)
    return unless params[:application] && params[:application][key].present?
    params[:application][key].read.chomp
  end

  def apply_server
    current_app.server.update_attribute(:working, true)
    current_app.server.update_attribute(:last_error, nil)
    if current_app.enable_ssl?
      ApplyServerWorker.perform_async(current_app.server.id)
    else
      RemoveSslCertificateJob.perform_later current_app.id
    end
  end
end
