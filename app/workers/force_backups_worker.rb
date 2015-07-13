class ForceBackupsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(application_id)
    app = Application.find(application_id)
    server = app.server
    ServerMaintainer.new(server).force_backup(app)
  end
end
