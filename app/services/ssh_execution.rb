class SshExecution
  def initialize(server)
    @server = server
  end

  # TODO: Remove the nil when upgrading to ruby 2.1
  def execute(command: nil, channeled: false)
    ssh_key_maintainer.create_key_for_connection
    run_ssh(command, channeled)
  ensure
    ssh_key_maintainer.delete_ssh_key_for_connection
  end

  def execute_with_password(command: nil, username: nil, password: nil)
    Net::SSH.start(@server.address, username,
                   port: @server.ssh_port, password: password,
                   paranoid: false, number_of_password_prompts: 1) do |ssh|
      ssh.exec!(command)
    end
  end

  private

  def ssh_key_maintainer
    @ssh_key_maintainer ||= SshKeyMaintainer.new(@server)
  end

  def run_ssh(command, channeled = false)
    Net::SSH.start(@server.address, @server.username,
                   port: @server.ssh_port,
                   keys: [ssh_key_maintainer.key], paranoid: false, timeout: 5,
                   number_of_password_prompts: 0) do |ssh|
      if channeled
        ssh.open_channel do |channel|
          channel.request_pty
          channel.exec(command)
          channel.on_data do |_ch, data|
            ServerLog.new(@server).logger.info(data.strip)
          end
        end
      else
        return ssh.exec!(command)
      end
    end
  end
end
