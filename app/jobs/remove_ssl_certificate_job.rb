class RemoveSslCertificateJob < ActiveJob::Base
  queue_as :default

  def perform(app_id)
    app = Application.find(app_id)
    SshExecution.new(app.server).
      execute(command: "sudo su - deploy -c \"rm /u/apps/#{app.name}/shared/" \
              "config/certificate.*\"")
    ApplyServerWorker.perform_async(app.server.id)
  end
end
