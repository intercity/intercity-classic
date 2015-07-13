class ApplyServerWorker
  include Sidekiq::Worker

  def perform(server_id)
    @server = Server.find(server_id)

    server_maintainer = ServerMaintainer.new(@server)
    server_maintainer.apply_configuration

    @server.update_attribute(:applied_at, Time.now)
    if @server.last_error.nil?
      # Email the user that server is done
    end
  ensure
    @server.update_attribute(:working, false)
  end
end
