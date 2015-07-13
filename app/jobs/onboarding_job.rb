class OnboardingJob < ActiveJob::Base
  queue_as :default

  def perform(server_id)
    server = Server.find(server_id)
    if server.digitalocean?
      BootstrapDigitaloceanWorker.new.perform(server_id)
    else
      BootstrapServerWorker.new.perform(server_id, server.username, nil)
    end
  end
end
