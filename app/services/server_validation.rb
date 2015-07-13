class ServerValidation
  def initialize(server, username, password)
    @server = server
    @username = username
    @password = password
  end

  def validate
    output = ""
    begin
      if test_mode?
        command_aggregator.add(check_version_command)
        return true
      else
        output = SshExecution.new(@server).execute_with_password(command: check_version_command,
                                                                 username: @username, password: @password)
      end
    rescue Errno::ETIMEDOUT
      @server.update(last_error: "Connect to SSH timed out, or server not reachable.")
      serverlog.fatal @server.last_error
      return false

    rescue Net::SSH::AuthenticationFailed
      @server.update(last_error: "SSH authentication failed.")
      serverlog.fatal @server.last_error
      return false

    rescue SocketError, Errno::ECONNREFUSED
      @server.update(last_error: "Could not connect to your server on"\
                     " #{@server.address}:#{@server.ssh_port}.")
      serverlog.fatal @server.last_error
      return false

    rescue => e
      @server.update(last_error: "Error: #{e.class.name}: #{e.message}.")
      serverlog.fatal @server.last_error
      return false
    end

    unless output.match "Release:(.*)"
      @server.update(last_error: "Your server is not running Ubuntu 12.04 LTS or 14.04 LTS.")
      serverlog.fatal @server.last_error
      return false
    end

    server_version = $1.strip
    unless supported_versions.include? server_version
      @server.update(last_error: "You have version #{server_version}, we only "\
                     "support: #{supported_versions.join(', ')}")
      serverlog.fatal @server.last_error
      return false
    end
    @server.update(server_version: server_version)
    true
  end

  private

  def command_aggregator
    @command_aggregator ||= CommandAggregator.new
  end

  def supported_versions
    %w(12.04 14.04)
  end

  def serverlog
    ServerLog.new(@server).logger
  end

  def test_mode?
    Rails.env.test?
  end

  def check_version_command
    @command ||= "lsb_release -r"
  end
end
