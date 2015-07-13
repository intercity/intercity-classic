class ApplySshKeysWorker
  include Sidekiq::Worker

  def perform(server_id)
    @server = Server.find(server_id)

    server_maintainer = ServerMaintainer.new(@server)
    server_maintainer.apply_ssh_keys

    @server.update_attribute(:applied_at, Time.now)
  ensure
    @server.update_attribute(:working, false)
  end
end
