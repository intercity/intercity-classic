class RemoveAppJob < ActiveJob::Base
  queue_as :default

  def perform(app_id)
    app = Application.with_deleted.find(app_id)
    server_maintainer = ServerMaintainer.new(app.server)
    server_maintainer.remove_application(app)
    app.server.update(applied_at: Time.now)
    app.destroy!
  ensure
    app.server.update(working: false)
    app.update!(deleting: false)
  end
end
