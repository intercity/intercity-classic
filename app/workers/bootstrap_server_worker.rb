class BootstrapServerWorker
  include Sidekiq::Worker

  def perform(server_id, username, password)
    @server = Server.find(server_id)

    server_maintainer = ServerMaintainer.new(@server)
    if server_maintainer.prepare(username, password)
      server_maintainer.apply_configuration
    end

    if @server.last_error.nil?
      ServerMailer.bootstrapped(@server.id).deliver
      @server.update(applied_at: Time.now, bootstrapped: true)
    else
      @server.update(applied_at: Time.now)
    end
  ensure
    @server.update_attribute(:working, false)
  end
end
