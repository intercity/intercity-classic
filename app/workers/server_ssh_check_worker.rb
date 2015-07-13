class ServerSshCheckWorker
  include Sidekiq::Worker
  MAX_TRIES = 6

  def perform(server_id, retries = 0)
    @server = Server.find(server_id)
    if ssh_active?
      BootstrapServerWorker.perform_in(20.seconds, server_id, @server.username, nil)
    elsif retries < MAX_TRIES
      ServerSshCheckWorker.perform_in(10.seconds, server_id, retries + 1)
    else
      @server.working = false
      @server.bootstrapped = false
      @server.last_error = "We have not been able to make a SSH connection. "\
                            "Server installation was unsuccesful"
      @server.save
    end
  end

  private

  def ssh_active?
    ServerMaintainer.new(@server).ssh_active?
  end
end
