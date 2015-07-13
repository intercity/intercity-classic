class ChefExecution
  def initialize(server)
    @server = server
  end

  def prepare(password)
    ssh_key_maintainer.create_key_for_connection
    command = build_command("prepare", "-p #{@server.ssh_port} -i #{ssh_key_maintainer.key} " \
                            "--omnibus-options '-d $HOME/.downloads' --no-host-key-verify")

    command << " -P $PASS" if password

    if test_mode?
      command_aggregator.add(command)
    else
      command << " 2>&1"

      IO.popen({ "PATH" => ENV["PATH"], "PASS" => password }, command, "r+") do |io|
        while output = io.gets
          serverlogger.info output.strip
        end
      end

      unless $?.success?
        @server.last_error = "Could not connect and prepare the server."
        serverlogger.fatal @server.last_error
        @server.save
      end
    end
  ensure
    ssh_key_maintainer.delete_ssh_key_for_connection
  end

  def cook(config, runlist, password = nil)
    ssh_key_maintainer.create_key_for_connection
    command = build_command("cook", "-j '#{config.to_json}' -p #{@server.ssh_port} -i " \
                            "#{ssh_key_maintainer.key} -r '#{runlist}' --no-host-key-verify")
    command << " -P $PASS" if password

    if test_mode?
      command_aggregator.add(command)
    else
      command << " 2>&1"

      IO.popen({ "PATH" => ENV["PATH"], "PASS" => password }, command, "r+") do |io|
        get_output(io)
      end

      unless $?.success?
        @server.last_error = "Could not apply changes."
        @server.save
      end
    end

    false
  ensure
    ssh_key_maintainer.delete_ssh_key_for_connection
  end

  def clean
    ssh_key_maintainer.create_key_for_connection
    command = build_command("clean", "-i #{ssh_key_maintainer.key} --no-host-key-verify "\
                            "-p #{@server.ssh_port} ")
    command << " 2>&1"
    IO.popen({ "PATH" => ENV["PATH"] }, command, "r+") do |io|
      get_output(io)
    end
  ensure
    ssh_key_maintainer.delete_ssh_key_for_connection
  end

  private

  def chef_repo_path
    Settings.chef_repo.path
  end

  def test_mode?
    Rails.env.test?
  end

  def command_aggregator
    @command_aggregator ||= CommandAggregator.new
  end

  def serverlogger
    ServerLog.new(@server).logger
  end

  def ssh_key_maintainer
    @ssh_key_maintainer ||= SshKeyMaintainer.new(@server)
  end

  def get_output(io)
    while output = io.gets
      serverlogger.info output.strip
      if output.include?("stty: stdin isn't a terminal") ||
         output.include?("stty: standard input: Invalid argument")
        serverlogger.fatal("Could not log in to server with user #{@server.username}." \
          "Did you change the .ssh/authorized_keys file on your server?")
        Process.kill("KILL", io.pid)
        break
      end
    end
    output
  end

  def build_command(command, params)
    "cd #{chef_repo_path}" \
      "&& rm -f nodes/#{@server.address}.json " \
      "&& bundle exec knife solo #{command} #{@server.username}@#{@server.address} " \
      "#{params}"
  end
end
